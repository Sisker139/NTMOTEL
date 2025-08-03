import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntmotel/models/motel_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<void> updateUserAvatar(String uid, String avatarUrl) async {
    await _db.collection('users').doc(uid).update({'avatarUrl': avatarUrl});
  }
  // Thêm người dùng mới vào collection 'users'
  Future<void> addUser(UserModel user) async {
    // Dùng uid từ Auth làm document ID
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  // Lấy thông tin người dùng từ Firestore
  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }


  // Đăng một phòng mới
  Future<void> addMotel(MotelModel motel) async {
    await _db.collection('motels').add(motel.toMap());
  }

  // Lấy danh sách tất cả các phòng trọ
  Stream<List<MotelModel>> getMotels() {
    return _db.collection('motels').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => MotelModel.fromMap(doc.data(), doc.id))
        .toList());
  }
}