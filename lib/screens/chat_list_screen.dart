// lib/screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // THÊM: import này
import '../models/chat_models.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  // THÊM: Hàm định dạng thời gian cho danh sách chat
  String _formatChatTimestamp(Timestamp timestamp) {
    final DateTime messageTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inDays == 0 && now.day == messageTime.day) {
      // Hôm nay -> Hiển thị giờ
      return DateFormat('HH:mm').format(messageTime);
    } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != messageTime.day)) {
      // Hôm qua
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      // Trong tuần -> Hiển thị thứ
      // Để hiển thị tiếng Việt, bạn cần cài đặt locale trong main.dart
      return DateFormat('E', 'vi_VN').format(messageTime);
    } else {
      // Cũ hơn -> Hiển thị ngày/tháng/năm
      return DateFormat('dd/MM/yyyy').format(messageTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatService = ChatService();
    final currentUser = authProvider.userModel;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tin nhắn'),
          backgroundColor: Colors.lightBlueAccent, // Thêm dòng này
        ),
        body: const Center(child: Text('Vui lòng đăng nhập')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tin nhắn'),backgroundColor: Colors.lightBlueAccent, automaticallyImplyLeading: false),
      body: StreamBuilder<List<ChatRoomModel>>(
        stream: chatService.getChatRooms(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Bạn chưa có cuộc trò chuyện nào.',style: TextStyle(fontSize: 18, color: Colors.grey)));
          }
          final chatRooms = snapshot.data!;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final otherUserId = chatRoom.participants.firstWhere((id) => id != currentUser.uid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    // Trả về một ListTile trống trong khi chờ
                    return const ListTile();
                  }
                  final otherUser = UserModel.fromMap(userSnapshot.data!.data() as Map<String, dynamic>);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: otherUser.avatarUrl != null ? NetworkImage(otherUser.avatarUrl!) : null,
                      child: otherUser.avatarUrl == null ? const Icon(Icons.person) : null,
                    ),
                    title: Text(otherUser.displayName ?? 'Người dùng', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(chatRoom.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                    // THÊM: Thuộc tính trailing để hiển thị thời gian
                    trailing: Text(
                      _formatChatTimestamp(chatRoom.lastMessageTimestamp),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(otherUser: otherUser),
                      ));
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}