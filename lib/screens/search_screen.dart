// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntmotel/models/motel_model.dart';
import 'home_tab_screen.dart'; // Import để tái sử dụng buildMotelCard

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi trong ô tìm kiếm
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        // Tạo ô nhập liệu tìm kiếm ngay trên AppBar
        title: TextField(
          controller: _searchController,
          autofocus: true, // Tự động mở bàn phím khi vào màn hình
          decoration: InputDecoration(
            hintText: 'Tìm kiếm theo tên nhà trọ...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    // Nếu người dùng chưa gõ gì, hiển thị hướng dẫn
    if (_searchQuery.isEmpty) {
      return const Center(
        child: Text(
          'Nhập tên phòng trọ bạn muốn tìm kiếm.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    final searchQueryLower = _searchQuery.toLowerCase();
    // Dùng StreamBuilder để hiển thị kết quả theo thời gian thực
    return StreamBuilder<QuerySnapshot>(
      // Firestore không hỗ trợ tìm kiếm "contains", nhưng có thể giả lập
      // truy vấn "starts-with" (bắt đầu bằng) một cách hiệu quả như sau:
      stream: FirebaseFirestore.instance
          .collection('motels')
          .where('isAvailable', isEqualTo: true) // Chỉ tìm phòng còn trống
          .where('name_lowercase', isGreaterThanOrEqualTo: searchQueryLower)
          .where('name_lowercase', isLessThanOrEqualTo: '$searchQueryLower\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Không tìm thấy kết quả nào.'));
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final motel = MotelModel.fromMap(
              docs[index].data() as Map<String, dynamic>,
              docs[index].id,
            );
            // Tái sử dụng widget card từ home_tab_screen
            return buildMotelCard(context, motel);
          },
        );
      },
    );
  }
}