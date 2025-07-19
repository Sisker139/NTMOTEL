import 'package:flutter/material.dart';
import 'package:ntmotel/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bước 1: Lấy thông tin từ AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    // Nếu dữ liệu người dùng chưa tải xong, hiển thị vòng quay
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Giao diện gốc của bạn, đã được cập nhật
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
                // Bước 2: Cập nhật Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                      ? const Icon(Icons.person, size: 30, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      // Bước 3: Cập nhật lời chào
                      Text("Chào, ${user.displayName ?? 'Người dùng'}!",
                          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
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

          // Section: Tài khoản và Ưu đãi
          _sectionTitle("Tài khoản và Ưu đãi"),
          // Bước 4: Thêm dòng ưu đãi
          _tile(icon: Icons.card_giftcard_outlined, title: "Ưu đãi của bạn"),
          _tile(icon: Icons.security, title: "Bảo mật & Quyền riêng tư"),

          // Bước 5: Thêm nút đăng xuất
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Đăng xuất', style: TextStyle(fontSize: 15, color: Colors.red)),
                onTap: () {
                  // Hiển thị hộp thoại xác nhận khi nhấn đăng xuất
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xác nhận'),
                      content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Hủy'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        TextButton(
                          child: const Text('Đăng xuất'),
                          onPressed: () {
                            Navigator.of(ctx).pop(); // Đóng hộp thoại
                            authProvider.signOut(); // Thực hiện đăng xuất
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(height: 0),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ---------- Helper Widgets (Giữ nguyên) ----------
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