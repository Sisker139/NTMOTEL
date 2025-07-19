import 'package:flutter/material.dart';
import 'package:ntmotel/screens/profile_screen.dart';
import 'package:ntmotel/screens/save_screen.dart';
import 'package:ntmotel/screens/Post_screen.dart';
import 'package:ntmotel/screens/contact_screen.dart';
import 'package:ntmotel/screens/home_tab_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với từng tab
  final List<Widget> _screens = [
    const HometabScreen(),
    const SaveScreen(),
    const ContactScreen(),
    const PostScreen(),
    const ProfileScreen(), // Đây là nơi liên kết thật sự
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      // Đây là nơi hiển thị màn hình tương ứng
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
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Liên hệ"),
          BottomNavigationBarItem(icon: Icon(Icons.edit_square), label: "Bảng tin"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
        ],
      ),
    );
  }
}
