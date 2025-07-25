import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  // Chuyển đổi từ Map (dữ liệu nhận từ Firestore) sang object UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      avatarUrl: map['avatarUrl'],
      role: map['role'] ?? 'tenant', // Mặc định là người thuê
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  // Chuyển đổi từ object UserModel sang Map (để ghi lên Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'role': role,
      'createdAt': createdAt,
    };
  }
}