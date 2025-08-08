// lib/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_models.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy stream các phòng chat của người dùng
  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatRoomModel.fromMap(doc)).toList();
    });
  }

  // Lấy stream các tin nhắn trong một phòng chat
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Gửi một tin nhắn
  Future<void> sendMessage(String chatRoomId, MessageModel message) async {
    // Thêm tin nhắn vào subcollection
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toMap());

    // Cập nhật tin nhắn cuối cùng trong document cha
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'lastMessage': message.text,
      'lastMessageTimestamp': message.timestamp,
    }, SetOptions(merge: true));
  }

  // Hàm helper để tạo hoặc lấy chatRoomId
  String getChatRoomId(String uid1, String uid2) {
    if (uid1.compareTo(uid2) < 0) {
      return '${uid1}_${uid2}';
    } else {
      return '${uid2}_${uid1}';
    }
  }

  // Hàm helper để tạo phòng chat nếu chưa có
  Future<void> createChatRoomIfNotExist(String chatRoomId, String uid1, String uid2) async {
    final doc = await _firestore.collection('chat_rooms').doc(chatRoomId).get();
    if (!doc.exists) {
      await _firestore.collection('chat_rooms').doc(chatRoomId).set({
        'participants': [uid1, uid2],
        'lastMessage': 'Hãy bắt đầu cuộc trò chuyện!',
        'lastMessageTimestamp': Timestamp.now(),
      });
    }
  }
}