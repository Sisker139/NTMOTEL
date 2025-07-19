import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Hàm tải ảnh đại diện lên và trả về URL
  Future<String?> uploadAvatar(String uid, File imageFile) async {
    try {
      // Tạo một tham chiếu đến vị trí lưu file trên Storage
      // Dùng uid để đảm bảo mỗi người dùng chỉ có 1 avatar, ghi đè lên cái cũ
      Reference ref = _storage.ref().child('avatars').child('$uid.jpg');

      // Tải file lên
      UploadTask uploadTask = ref.putFile(imageFile);

      // Chờ cho đến khi tải lên hoàn tất
      TaskSnapshot snapshot = await uploadTask;

      // Lấy URL của file vừa tải lên
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }
}