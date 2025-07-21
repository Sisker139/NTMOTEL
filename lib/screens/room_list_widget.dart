import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntmotel/models/room_model.dart';

class RoomListWidget extends StatelessWidget {
  const RoomListWidget({super.key});

  String getAddressString(Map<String, String> address) {
    // Ghép địa chỉ: ví dụ ["street", "ward", "district", "city"]
    return [
      address['street'],
      address['ward'],
      address['district'],
      address['city'],
    ].where((e) => e != null && e.isNotEmpty).join(', ');
  }

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
            final room = RoomModel.fromMap(data, docs[index].id);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh minh họa (lấy ảnh đầu tiên)
                  if (room.images.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        room.images.first,
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
                          children: [
                            Expanded(
                              child: Text(
                                room.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'VND ${room.price.toStringAsFixed(0)}',
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
                                getAddressString(room.address),
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Tiện nghi
                        Wrap(
                          spacing: 6,
                          runSpacing: -8,
                          children: room.amenities
                              .map((amenity) => Chip(
                            label: Text(amenity, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.grey[200],
                          ))
                              .toList(),
                        ),
                        // Diện tích, mô tả (tuỳ ý bạn thêm)
                        // Text('${room.area} m²'),
                        // Text(room.description, maxLines: 2, overflow: TextOverflow.ellipsis),
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
