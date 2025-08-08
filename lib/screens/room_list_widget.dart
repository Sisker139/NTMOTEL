import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntmotel/models/motel_model.dart';
import 'package:intl/intl.dart'; // Thêm thư viện intl để định dạng số

class RoomListWidget extends StatelessWidget {
  const RoomListWidget({super.key});

  // HÀM NÀY KHÔNG CÒN CẦN THIẾT VÌ `position` TRONG MODEL LÀ `String`
  // String getAddressString(Map<String, String> address) { ... }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('motels').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Lỗi tải dữ liệu"));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("Chưa có phòng trọ nào!"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            // SỬA LẠI: Đổi tên biến `room` thành `motel` cho nhất quán
            final motel = MotelModel.fromMap(data, docs[index].id);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh minh họa (lấy ảnh đầu tiên)
                  if (motel.images.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        motel.images.first,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, s) => const SizedBox(
                          height: 180,
                          child: Center(child: Icon(Icons.broken_image, size: 60)),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tiêu đề, giá
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start, // Giúp căn chỉnh tốt hơn
                          children: [
                            Expanded(
                              child: Text(
                                motel.name, // SỬA LẠI: Dùng motel.name
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8), // Thêm khoảng cách
                            Text(
                              // SỬA LẠI: Dùng NumberFormat để định dạng giá tiền
                              '${NumberFormat.decimalPattern('vi_VN').format(motel.monthlyPrice)} VNĐ',
                              style: const TextStyle(
                                  color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Địa chỉ
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 15, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                // SỬA LẠI: Dùng trực tiếp motel.position và xử lý null
                                motel.address,
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                                maxLines: 2, // Cho phép hiển thị 2 dòng
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Tiện nghi
                        if (motel.amenities.isNotEmpty) // Chỉ hiển thị nếu có tiện nghi
                          Wrap(
                            spacing: 6,
                            runSpacing: 4, // Điều chỉnh khoảng cách dọc
                            children: motel.amenities
                                .map((amenity) => Chip(
                              label: Text(amenity, style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.grey[200],
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}