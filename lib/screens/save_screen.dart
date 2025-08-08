// lib/screens/save_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../models/motel_model.dart';
import 'home_tab_screen.dart'; // Tái sử dụng widget card từ HomeTabScreen

class SaveScreen extends StatelessWidget {
  const SaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đã lưu'),
        backgroundColor: Colors.lightBlueAccent,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Lấy danh sách ID đã lưu
          final savedIds = authProvider.userModel?.savedMotelIds ?? [];

          if (savedIds.isEmpty) {
            return const Center(
              child: Text(
                'Bạn chưa lưu phòng nào.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Dùng StreamBuilder và truy vấn 'whereIn' để lấy thông tin các phòng đã lưu
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('motels')
                .where(FieldPath.documentId, whereIn: savedIds)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Không tìm thấy phòng đã lưu.'));
              }

              final docs = snapshot.data!.docs;

              // Tái sử dụng lại widget _buildMotelCard từ HomeTabScreen
              // Lưu ý: Cần public hàm _buildMotelCard hoặc tạo 1 widget chung
              // Ở đây ta tạm định nghĩa lại một widget tương tự để đơn giản
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final motel = MotelModel.fromMap(
                    docs[index].data() as Map<String, dynamic>,
                    docs[index].id,
                  );
                  // Gọi lại hàm build card (hoặc widget card chung của bạn)
                  // Vì _buildMotelCard là private, ta tạo một bản sao ở đây
                  return buildMotelCard(context, motel);
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Để có thể gọi `HomeTabScreen().buildMotelCard`, bạn cần sửa lại một chút ở home_tab_screen.dart
// Chuyển hàm _buildMotelCard ra ngoài class hoặc làm nó public (bỏ dấu _)
// Cách đơn giản nhất là sửa lại hàm _buildMotelCard thành public như sau:
/*
  // Trong file home_tab_screen.dart
  class HomeTabScreen extends StatelessWidget {
    ...
    // Bỏ dấu gạch dưới _ ở đây
    Widget buildMotelCard(BuildContext context, MotelModel motel) { ... }
    ...
  }
*/