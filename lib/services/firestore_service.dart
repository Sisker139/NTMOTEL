import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';
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
  Future<void> addRoom(RoomModel room) async {
    // Firestore sẽ tự tạo document ID
    await _db.collection('rooms').add(room.toMap());
  }

  // Lấy danh sách tất cả các phòng
  Stream<List<RoomModel>> getRooms() {
    return _db.collection('rooms').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
        .toList());
  }
}