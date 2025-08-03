// lib/models/motel_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MotelModel {
  final String? id;
  final String name;
  final String description;
  final int monthlyPrice;
  final List<String> images;
  final List<String> amenities;
  final String? position;
  final Timestamp? createdAt;

  MotelModel({
    this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.images,
    required this.amenities,
    this.position,
    this.createdAt,
  });

  factory MotelModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MotelModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      monthlyPrice: map['monthlyPrice'] is int
          ? map['monthlyPrice']
          : int.tryParse(map['monthlyPrice'].toString()) ?? 0,
      images: List<String>.from(map['images'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      position: map['position']?.toString(),
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'monthlyPrice': monthlyPrice,
      'images': images,
      'amenities': amenities,
      'position': position,
      'createdAt': createdAt,
    };
  }
}
