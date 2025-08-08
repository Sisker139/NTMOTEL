// lib/screens/chat_room_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/chat_models.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import 'package:intl/intl.dart';
// THÊM: import cần thiết cho việc điều hướng
import '../models/motel_model.dart';
import 'motel_detail_screen.dart';


class ChatRoomScreen extends StatefulWidget {
  final UserModel otherUser;
  const ChatRoomScreen({super.key, required this.otherUser});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = Provider.of<AuthProvider>(context, listen: false).userModel!;
    final chatRoomId = _chatService.getChatRoomId(currentUser.uid, widget.otherUser.uid);

    // SỬA: Thêm messageType khi gửi tin nhắn văn bản
    final message = MessageModel(
      senderId: currentUser.uid,
      receiverId: widget.otherUser.uid,
      timestamp: Timestamp.now(),
      messageType: 'text', // Bắt buộc phải có
      text: _messageController.text.trim(),
    );

    _chatService.sendMessage(chatRoomId, message);
    _messageController.clear();

    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).userModel!;
    final chatRoomId = _chatService.getChatRoomId(currentUser.uid, widget.otherUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser.displayName ?? 'Trò chuyện'),backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(chatRoomId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemBuilder: (context, index) {
                    final messageData = messages[messages.length - 1 - index].data() as Map<String, dynamic>;

                    // SỬA: Kiểm tra loại tin nhắn
                    final messageType = messageData['messageType'] ?? 'text';

                    if (messageType == 'motel_link') {
                      // Nếu là tin nhắn liên kết, build widget thẻ
                      return _buildMotelLinkBubble(context, messageData);
                    } else {
                      // Nếu là tin nhắn thường, build bong bóng chat
                      final isMe = messageData['senderId'] == currentUser.uid;
                      final timestamp = messageData['timestamp'] as Timestamp;
                      final formattedTime = DateFormat('HH:mm').format(timestamp.toDate());
                      return _buildTextBubble(isMe, messageData['text'], formattedTime);
                    }
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // THÊM: Widget để hiển thị thẻ liên kết phòng trọ
  Widget _buildMotelLinkBubble(BuildContext context, Map<String, dynamic> messageData) {
    final currencyFormatter = NumberFormat.decimalPattern('vi_VN');
    final isMe = messageData['senderId'] == Provider.of<AuthProvider>(context, listen: false).userModel!.uid;

    // Căn lề cho thẻ, tương tự tin nhắn thường
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        width: 250, // Giới hạn chiều rộng của thẻ
        child: GestureDetector(
          onTap: () async {
            // Khi nhấn vào thẻ, lấy đầy đủ thông tin phòng và điều hướng
            final motelId = messageData['motelId'];
            if (motelId != null) {
              final doc = await FirebaseFirestore.instance.collection('motels').doc(motelId).get();
              if (doc.exists) {
                final motel = MotelModel.fromMap(doc.data()!, doc.id);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MotelDetailScreen(motel: motel),
                ));
              }
            }
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: messageData['motelImage'] != null
                        ? Image.network(messageData['motelImage'], width: 60, height: 60, fit: BoxFit.cover)
                        : Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.apartment)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          messageData['motelName'] ?? 'Phòng trọ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${currencyFormatter.format(messageData['motelPrice'] ?? 0)} VNĐ',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Giao diện bong bóng chat văn bản (code cũ của bạn được tách ra đây)
  Widget _buildTextBubble(bool isMe, String? text, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 4,
              bottom: 2,
              left: isMe ? 60 : 12,
              right: isMe ? 12 : 60,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text ?? '', // Dùng text ?? '' để tránh lỗi null
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration.collapsed(hintText: 'Nhập tin nhắn...'),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}