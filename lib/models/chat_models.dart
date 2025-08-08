// lib/models/chat_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Model cho một tin nhắn
class MessageModel {
  final String senderId;
  final String receiverId;
  final Timestamp timestamp;

  // Các trường sẽ thay đổi
  final String messageType; // 'text' hoặc 'motel_link'
  final String? text; // Dành cho messageType 'text'

  // Các trường dành riêng cho messageType 'motel_link'
  final String? motelId;
  final String? motelName;
  final String? motelImage;
  final int? motelPrice;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    required this.messageType,
    this.text,
    this.motelId,
    this.motelName,
    this.motelImage,
    this.motelPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'messageType': messageType,
      'text': text,
      'motelId': motelId,
      'motelName': motelName,
      'motelImage': motelImage,
      'motelPrice': motelPrice,
    };
  }
}

// Model cho một phòng chat (để hiển thị trên danh sách)
class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final Timestamp lastMessageTimestamp;

  ChatRoomModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });

  factory ChatRoomModel.fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] ?? Timestamp.now(),
    );
  }
}