import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ntmotel/models/user_model.dart';
import 'package:ntmotel/services/auth_service.dart';
import 'package:ntmotel/services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _userModel = null;
    } else {
      _user = firebaseUser;
      // Lấy thông tin chi tiết từ Firestore
      _userModel = await _firestoreService.getUser(firebaseUser.uid);
    }
    // Xóa thông báo lỗi cũ và trạng thái loading
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    await _authService.signInWithEmailAndPassword(email, password);
    // onAuthStateChanged sẽ tự động xử lý phần còn lại
    // Nếu có lỗi, _authService sẽ throw exception và ta sẽ bắt nó
    // (Trong phiên bản nâng cao, ta sẽ bắt lỗi ở đây)
    // Tạm thời, onAuthStateChanged sẽ xóa trạng thái loading
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    _setLoading(true);
    User? firebaseUser =
    await _authService.signUpWithEmailAndPassword(email, password);

    if (firebaseUser != null) {
      UserModel newUser = UserModel(
        uid: firebaseUser.uid,
        email: email,
        displayName: displayName,
        role: role,
        createdAt: Timestamp.now(),
      );
      await _firestoreService.addUser(newUser);
      // onAuthStateChanged sẽ tự động xử lý phần còn lại
    }
    // Tạm thời, onAuthStateChanged sẽ xóa trạng thái loading
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _errorMessage = null; // Xóa lỗi cũ khi bắt đầu một hành động mới
    }
    notifyListeners();
  }
}