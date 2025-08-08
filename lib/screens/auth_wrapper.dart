// lib/screens/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:ntmotel/providers/auth_provider.dart';
import 'package:ntmotel/screens/home_screen.dart';
import 'package:ntmotel/screens/login_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // SỬA: Dùng `userModel` từ AuthProvider mới để kiểm tra
    if (authProvider.userModel != null) {
      // Nếu đã đăng nhập và có thông tin, vào trang chủ
      return const HomeScreen();
    } else {
      // Nếu chưa, vào trang đăng nhập
      return const LoginScreen();
    }
  }
}