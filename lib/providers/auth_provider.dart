// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart' as model;
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../services/notification_service.dart';


class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  model.UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  model.UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Lắng nghe trạng thái đăng nhập ngay khi provider được tạo
    _auth.authStateChanges().listen((User? firebaseUser) {
      // Gọi hàm async của bạn từ bên trong một hàm đồng bộ
      _onAuthStateChanged(firebaseUser);
    });
  }

  // Giữ lại hàm này và xóa hàm còn lại
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _userModel = null;
    } else {
      await _fetchUserModel(firebaseUser.uid);
      if (_userModel != null) {
        await NotificationService().init(firebaseUser.uid);
      }
    }
    notifyListeners();
  }

  Future<void> _fetchUserModel(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        _userModel = model.UserModel.fromMap(docSnapshot.data()!);
      }
    } catch (e) {
      print("Lỗi khi fetch user model: $e");
      _userModel = null;
    }
  }

  Future<bool> updateUserProfile({
    required String displayName,
    String? phoneNumber,
    XFile? imageFile,
  }) async {
    if (_userModel == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      String? avatarUrl;
      if (imageFile != null) {
        final ref = FirebaseStorage.instance.ref().child('avatars').child('${_userModel!.uid}.jpg');
        await ref.putFile(File(imageFile.path));
        avatarUrl = await ref.getDownloadURL();
      }
      Map<String, dynamic> dataToUpdate = {
        'displayName': displayName,
        'phoneNumber': phoneNumber,
      };
      if (avatarUrl != null) {
        dataToUpdate['avatarUrl'] = avatarUrl;
      }
      await _firestore.collection('users').doc(_userModel!.uid).update(dataToUpdate);
      if (_auth.currentUser?.displayName != displayName) {
        await _auth.currentUser?.updateDisplayName(displayName);
      }
      await _fetchUserModel(_userModel!.uid);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Lỗi khi cập nhật profile: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_userModel == null || _auth.currentUser == null) {
      _errorMessage = "Người dùng không hợp lệ.";
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final cred = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: oldPassword,
      );
      await _auth.currentUser!.reauthenticateWithCredential(cred);
      await _auth.currentUser!.updatePassword(newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _errorMessage = 'Mật khẩu cũ không chính xác.';
      } else {
        _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
      }
      print("Lỗi đổi mật khẩu: ${e.message}");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }



  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // SỬA LỖI 1: Hàm signUp cần trả về true/false
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(displayName);
        model.UserModel newUser = model.UserModel(
          uid: firebaseUser.uid,
          email: email,
          displayName: displayName,
          role: role,
          createdAt: Timestamp.now(),
          savedMotelIds: [],
        );
        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
        _userModel = newUser;
      }
      _isLoading = false;
      notifyListeners();
      return true; // Trả về true khi thành công
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false; // Trả về false khi thất bại
    }
  }

  // SỬA LỖI 2: Thêm notifyListeners() để UI cập nhật
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String motelId) async {
    if (_userModel == null) return;
    final uid = _userModel!.uid;
    final isCurrentlySaved = _userModel!.savedMotelIds.contains(motelId);
    if (isCurrentlySaved) {
      _userModel!.savedMotelIds.remove(motelId);
      await _firestore.collection('users').doc(uid).update({
        'savedMotelIds': FieldValue.arrayRemove([motelId])
      });
    } else {
      _userModel!.savedMotelIds.add(motelId);
      await _firestore.collection('users').doc(uid).update({
        'savedMotelIds': FieldValue.arrayUnion([motelId])
      });
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }
}