import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String? id; // Document ID của phòng
  final String landlordId;
  final String title;
  final String description;
  final double price;
  final double area;
  final Map<String, String> address;
  final List<String> images;
  final List<String> amenities;
  final bool isAvailable;
  final Timestamp createdAt;

  RoomModel({
    this.id,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.price,
    required this.area,
    required this.address,
    required this.images,
    required this.amenities,
    required this.isAvailable,
    required this.createdAt,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map, String documentId) {
    return RoomModel(
      id: documentId,
      landlordId: map['landlordId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      area: (map['area'] ?? 0).toDouble(),
      address: Map<String, String>.from(map['address'] ?? {}),
      images: List<String>.from(map['images'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'landlordId': landlordId,
      'title': title,
      'description': description,
      'price': price,
      'area': area,
      'address': address,
      'images': images,
      'amenities': amenities,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
    };
  }
}