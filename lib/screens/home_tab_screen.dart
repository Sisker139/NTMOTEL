import 'package:flutter/material.dart';
import 'package:ntmotel/providers/auth_provider.dart';
import 'package:ntmotel/screens/post_screen.dart';
import 'package:provider/provider.dart';
import 'package:ntmotel/screens/add_motel_page.dart';


class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  // Widget để hiển thị banner đăng tin
  Widget _buildPostRoomBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddMotelPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF00A680),
        ),
        child: Row(
          children: const [
            Icon(Icons.add_home_work_outlined, color: Colors.white, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Đăng nhà trọ trên\nNT Motel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLandlord = authProvider.userModel?.role == 'landlord';

    // Thêm Scaffold và AppBar vào đây
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        toolbarHeight: 120,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SizedBox(
                height: 50,
                child: Image.asset(
                  'assets/logo2.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Text("Tìm kiếm", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.chat_outlined, color: Colors.white),
                const SizedBox(width: 10),
                const Icon(Icons.notifications_outlined, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          if (isLandlord) _buildPostRoomBanner(context),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('Danh sách phòng trọ sẽ được hiển thị ở đây.'),
            ),
          ),
        ],
      ),
    );
  }
}