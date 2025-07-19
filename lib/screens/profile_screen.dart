import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // màu nền sáng
      body: ListView(
        children: [
          // Header
          Container(
            color: Colors.lightBlueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(''), // Hoặc NetworkImage
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Chào ...",
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),

                    ],
                  ),
                ),
                const Icon(Icons.chat_outlined, color: Colors.white),
                const SizedBox(width: 16),
                const Icon(Icons.notifications_outlined, color: Colors.white),
                const SizedBox(width: 10),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Section: Hoạt động du lịch
          _sectionTitle("Hoạt động du lịch"),
          _tile(icon: Icons.reviews, title: "Đánh giá của tôi"),
          _tile(icon: Icons.help_outline, title: "Câu hỏi cho chỗ nghỉ"),

          const SizedBox(height: 16),

          // Section: Trợ giúp
          _sectionTitle("Trợ giúp"),
          _tile(icon: Icons.support_agent, title: "Liên hệ dịch vụ khách hàng"),
          _tile(icon: Icons.security, title: "Trung tâm thông tin về bảo mật"),
          _tile(icon: Icons.handshake_outlined, title: "Giải quyết khiếu nại"),

          const SizedBox(height: 16),

          // Section: Pháp lý và quyền riêng tư
          _sectionTitle("Pháp lý và quyền riêng tư"),
          _tile(icon: Icons.privacy_tip_outlined, title: "Quản lý quyền riêng tư và dữ liệu"),
          _tile(icon: Icons.menu_book_outlined, title: "Hướng dẫn nội dung"),

          const SizedBox(height: 16),

          // Section: Khám phá
          _sectionTitle("Khám phá"),
          _tile(icon: Icons.percent, title: "Ưu đãi"),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ---------- Helper Widgets ----------
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
  );

  Widget _tile({required IconData icon, required String title}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(title, style: const TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(height: 0),
      ],
    );
  }
}
