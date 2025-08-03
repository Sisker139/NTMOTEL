import 'package:flutter/material.dart';
import 'package:ntmotel/providers/auth_provider.dart';
import 'package:ntmotel/screens/post_screen.dart';
import 'package:provider/provider.dart';
import 'package:ntmotel/screens/add_motel_page.dart';
import 'package:ntmotel/screens/room_list_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntmotel/models/motel_model.dart';
import 'package:intl/intl.dart';

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

      body: Column(
        children: [
          if (isLandlord) _buildPostRoomBanner(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('motels').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('Chưa có phòng trọ nào!'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final motel = MotelModel.fromMap(
                      docs[index].data() as Map<String, dynamic>,
                      docs[index].id,
                    );

                    return _buildMotelCard(motel);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotelCard(MotelModel motel) {
    // Dòng code được thêm vào
    final formattedPrice = NumberFormat.decimalPattern('vi_VN').format(motel.monthlyPrice);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (motel.images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12)),
              child: Image.network(
                motel.images.first,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  motel.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      // Dòng code được thay đổi
                      '$formattedPrice VND/tháng',
                      style: const TextStyle(fontSize: 16,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  motel.description,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: motel.amenities
                      .map((e) => Chip(label: Text(e)))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}