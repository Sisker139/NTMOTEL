// lib/models/motel_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MotelModel {
  final String? id;
  final String landlordId;
  final String name;
  final String description;
  final int monthlyPrice;
  final List<String> images;
  final List<String> amenities; // Sẽ dùng cho danh sách tiện ích
  final double? latitude;
  final double? longitude;
  final Timestamp? createdAt;
  final bool isAvailable;
  final String province; // V
  final String ward;
  final String address; // Địa chỉ chi tiết dạng text
  final int electricityCost; // Giá điện /kWh
  final int waterCost; // Giá nước /người
  final int parkingCost; // Phí gửi xe /xe
  final int managementFee; // Phí quản lý /phòng
  final int wifiCost; // Phí wifi /phòng
  final double area; // Diện tích m2
  final int maxOccupants; // Số người ở tối đa
  final int vehicleLimit; // Số xe tối đa
  final bool isFreeHours; // Giờ giấc tự do
  final bool liveWithOwner; // Có chung chủ không


  MotelModel({
    this.id,
    required this.landlordId,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.images,
    required this.amenities,
    required this.province,
    required this.ward,

    this.createdAt,
    required this.address,
    this.electricityCost = 0,
    this.waterCost = 0,
    this.parkingCost = 0,
    this.managementFee = 0,
    this.wifiCost = 0,
    this.area = 0.0,
    this.maxOccupants = 1,
    this.vehicleLimit = 1,
    this.isFreeHours = true,
    this.liveWithOwner = false,
    this.isAvailable = true,
    this.latitude,
    this.longitude,
  });

  factory MotelModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MotelModel(
      id: documentId,
      landlordId: map['landlordId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      monthlyPrice: map['monthlyPrice'] ?? 0,
      images: List<String>.from(map['images'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      createdAt: map['createdAt'],
      // --- LẤY DỮ LIỆU CHO CÁC TRƯỜNG MỚI ---
      address: map['address'] ?? 'Chưa cập nhật địa chỉ',
      electricityCost: map['electricityCost'] ?? 0,
      waterCost: map['waterCost'] ?? 0,
      parkingCost: map['parkingCost'] ?? 0,
      managementFee: map['managementFee'] ?? 0,
      wifiCost: map['wifiCost'] ?? 0,
      area: (map['area'] ?? 0.0).toDouble(),
      maxOccupants: map['maxOccupants'] ?? 1,
      vehicleLimit: map['vehicleLimit'] ?? 1,
      isFreeHours: map['isFreeHours'] ?? true,
      liveWithOwner: map['liveWithOwner'] ?? false,
      isAvailable: map['isAvailable'] ?? true,
      province: map['province'] ?? '',
      ward: map['ward'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'landlordId': landlordId,
      'name': name,
      'name_lowercase': name.toLowerCase(),
      'description': description,
      'monthlyPrice': monthlyPrice,
      'images': images,
      'amenities': amenities,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
      // --- THÊM TRƯỜNG MỚI VÀO MAP ---
      'address': address,
      'electricityCost': electricityCost,
      'waterCost': waterCost,
      'parkingCost': parkingCost,
      'managementFee': managementFee,
      'wifiCost': wifiCost,
      'area': area,
      'maxOccupants': maxOccupants,
      'vehicleLimit': vehicleLimit,
      'isFreeHours': isFreeHours,
      'liveWithOwner': liveWithOwner,
      'isAvailable': isAvailable,
      'province': province,
      'ward': ward,
    };
  }
}