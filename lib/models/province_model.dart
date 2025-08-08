// lib/models/province_model.dart
import 'dart:convert';

// Class đại diện cho một Phường/Xã
class Ward {
  final String code;
  final String name;
  final String fullName;

  Ward({required this.code, required this.name, required this.fullName});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }
}

// Class đại diện cho một Tỉnh/Thành phố
class Province {
  final String code;
  final String name;
  final String fullName;
  final List<Ward> wards;

  Province({
    required this.code,
    required this.name,
    required this.fullName,
    required this.wards,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    var wardList = json['wards'] as List;
    List<Ward> wards = wardList.map((i) => Ward.fromJson(i)).toList();

    return Province(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      fullName: json['fullName'] ?? '',
      wards: wards,
    );
  }
}