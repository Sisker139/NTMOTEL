// lib/screens/motel_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:ntmotel/models/motel_model.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ntmotel/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntmotel/screens/add_motel_page.dart';
import 'package:ntmotel/services/chat_service.dart';
import 'package:ntmotel/screens/chat_room_screen.dart';
import 'package:ntmotel/models/user_model.dart';
import '../models/chat_models.dart';
import 'package:url_launcher/url_launcher.dart';

class MotelDetailScreen extends StatelessWidget {
  final MotelModel motel;

  const MotelDetailScreen({super.key, required this.motel});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.decimalPattern('vi_VN');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwner = authProvider.userModel?.uid == motel.landlordId;

    return Scaffold(
      appBar: AppBar(
        title: Text(motel.name),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddMotelPage(initialMotel: motel),
                ));
              },
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmationDialog(context, motel);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (motel.images.isNotEmpty) _buildImageCarousel(motel.images),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(motel.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // SỬA: Đặt giá và trạng thái trên cùng 1 hàng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Giá: ${currencyFormatter.format(motel.monthlyPrice)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)
                      ),
                      Chip(
                        label: Text(
                          motel.isAvailable ? 'Còn phòng' : 'Đã hết phòng',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: motel.isAvailable ? Colors.green : Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on_outlined, motel.address),
                  // ...
                ],
              ),
            ),
            const Divider(thickness: 6, color: Color(0xFFF2F2F2)),
            _buildSectionTitle('Chi phí dự kiến'),
            _buildCostsGrid(currencyFormatter, motel),
            const Divider(thickness: 6, color: Color(0xFFF2F2F2)),
            _buildSectionTitle('Thông tin chi tiết'),
            _buildDetails(motel),
            const Divider(thickness: 6, color: Color(0xFFF2F2F2)),
            _buildSectionTitle('Tiện ích'),
            _buildAmenitiesGrid(motel),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomActionBar(context, motel),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, MotelModel motel) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa phòng trọ này không? Hành động này không thể hoàn tác.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('motels').doc(motel.id).delete();
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return CarouselSlider.builder(
      itemCount: images.length,
      itemBuilder: (context, index, realIndex) {
        return Image.network(
          images[index],
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (c, o, s) => const Icon(Icons.broken_image, size: 60),
        );
      },
      options: CarouselOptions(
        height: 250,
        autoPlay: true,
        viewportFraction: 1.0,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 16, color: Colors.grey.shade800))),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCostsGrid(NumberFormat formatter, MotelModel motel) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildCostItem(formatter, 'Điện', motel.electricityCost, '/kWh'),
        _buildCostItem(formatter, 'Nước', motel.waterCost, '/ng'),
        _buildCostItem(formatter, 'Xe', motel.parkingCost, '/xe'),
        _buildCostItem(formatter, 'Quản lý', motel.managementFee, '/ph'),
      ],
    );
  }

  Widget _buildCostItem(NumberFormat formatter, String label, int value, String unit) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(formatter.format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(unit, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildDetails(MotelModel motel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildDetailRow('Số người ở:', '${motel.maxOccupants} người'),
          _buildDetailRow('Số lượng xe:', '${motel.vehicleLimit} xe'),
          _buildDetailRow('Diện tích:', '${motel.area}m²'),
          _buildDetailRow('Chung chủ:', motel.liveWithOwner ? 'Có' : 'Không'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid(MotelModel motel) {
    final Map<String, IconData> allAmenities = {
      'Gác': Icons.stairs_outlined,
      'Cửa sổ': Icons.window_outlined,
      'Tủ lạnh': Icons.kitchen_outlined,
      'Máy lạnh': Icons.ac_unit_outlined,
      'Giường': Icons.king_bed_outlined,
      'Nệm': Icons.king_bed,
      'Tủ quần áo': Icons.checkroom_outlined,
      'Thang máy': Icons.elevator_outlined,
      'Nước nóng': Icons.hot_tub_outlined,
      'Thú cưng': Icons.pets_outlined,
      'Máy giặt': Icons.local_laundry_service_outlined,
    };

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
      ),
      itemCount: allAmenities.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        String key = allAmenities.keys.elementAt(index);
        IconData icon = allAmenities.values.elementAt(index);
        bool isAvailable = motel.amenities.contains(key);
        return _buildAmenityItem(icon, key, isAvailable);
      },
    );
  }

  Widget _buildAmenityItem(IconData icon, String label, bool isAvailable) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isAvailable ? Icons.check_circle : Icons.cancel,
          color: isAvailable ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }

  // THÊM: Hàm helper mới để xử lý logic mở phòng chat
  Future<void> _navigateToChatRoom(BuildContext context, MotelModel motel, {bool sendMotelLink = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.userModel;
    final landlordId = motel.landlordId;

    if (currentUser != null && landlordId.isNotEmpty && currentUser.uid != landlordId) {
      final chatService = ChatService();
      final landlordDoc = await FirebaseFirestore.instance.collection('users').doc(landlordId).get();

      if (landlordDoc.exists) {
        final landlordUser = UserModel.fromMap(landlordDoc.data()!);
        final chatRoomId = chatService.getChatRoomId(currentUser.uid, landlordId);

        await chatService.createChatRoomIfNotExist(chatRoomId, currentUser.uid, landlordId);

        if (sendMotelLink) {
          final motelLinkMessage = MessageModel(
            senderId: currentUser.uid,
            receiverId: landlordId,
            timestamp: Timestamp.now(),
            messageType: 'motel_link',
            motelId: motel.id,
            motelName: motel.name,
            motelImage: motel.images.isNotEmpty ? motel.images.first : null,
            motelPrice: motel.monthlyPrice,
          );
          await chatService.sendMessage(chatRoomId, motelLinkMessage);
        }

        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ChatRoomScreen(otherUser: landlordUser),
        ));
      }
    } else if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để có thể trò chuyện.'))
      );
    }
  }

  // THAY THẾ: Hàm build thanh chức năng dưới cùng
  Widget _buildBottomActionBar(BuildContext context, MotelModel motel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _navigateToChatRoom(context, motel, sendMotelLink: true),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Đặt lịch xem phòng', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
              onPressed: () => _navigateToChatRoom(context, motel, sendMotelLink: false),
              icon: const Icon(Icons.chat_outlined, color: Colors.blue, size: 28)
          ),
          IconButton(
              onPressed: () async {
                // 1. Lấy ID của chủ trọ từ thông tin phòng
                final landlordId = motel.landlordId;

                // 2. Lấy thông tin chi tiết của chủ trọ từ collection 'users'
                final landlordDoc = await FirebaseFirestore.instance.collection('users').doc(landlordId).get();

                if (landlordDoc.exists) {
                  final phoneNumber = landlordDoc.data()?['phoneNumber'] as String?;

                  // 3. Kiểm tra xem chủ trọ có số điện thoại không
                  if (phoneNumber != null && phoneNumber.isNotEmpty) {
                    final Uri phoneUri = Uri.parse('tel:$phoneNumber');

                    // 4. Mở ứng dụng gọi điện
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không thể thực hiện cuộc gọi.'))
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chủ trọ chưa cập nhật số điện thoại.'))
                    );
                  }
                }
              },
              icon: const Icon(Icons.call_outlined, color: Colors.blue, size: 28)
          ),
        ],
      ),
    );
  }
}