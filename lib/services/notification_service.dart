// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init(String userId) async {
    // 1. Yêu cầu quyền nhận thông báo từ người dùng
    await _fcm.requestPermission();

    // 2. Lấy FCM Token của thiết bị
    final fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      print("FCM Token: $fcmToken");
      // 3. Lưu token này vào hồ sơ người dùng trên Firestore
      await saveTokenToDatabase(userId, fcmToken);
      // Lắng nghe nếu token thay đổi và cập nhật lại
      _fcm.onTokenRefresh.listen((newToken) {
        saveTokenToDatabase(userId, newToken);
      });
    }

    // 4. Cấu hình để hiển thị thông báo khi app đang mở (foreground)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher', // Đảm bảo bạn có icon này
            ),
          ),
        );
      }
    });
  }

  Future<void> saveTokenToDatabase(String userId, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayUnion([token])
    });
  }
}