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

    // Dựa vào trạng thái user từ provider để quyết định
    if (authProvider.user != null) {
      // Nếu đã đăng nhập, vào trang chủ
      return const HomeScreen();
    } else {
      // Nếu chưa, vào trang đăng nhập
      return const LoginScreen();
    }
  }
}