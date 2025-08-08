import 'package:flutter/material.dart';
import 'package:ntmotel/screens/profile_screen.dart';
import 'package:ntmotel/screens/save_screen.dart';
import 'package:ntmotel/screens/home_tab_screen.dart';
// THÊM: Import cho màn hình danh sách chat
import 'package:ntmotel/screens/chat_list_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // SỬA: Cập nhật danh sách các màn hình
  final List<Widget> _screens = [
    const HomeTabScreen(),
    const SaveScreen(),
    const ChatListScreen(), // Thay ContactScreen bằng ChatListScreen
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Đã lưu"),
          // SỬA: Đổi nhãn cho tab thứ 3
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Tin nhắn"),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
        ],
      ),
    );
  }
}