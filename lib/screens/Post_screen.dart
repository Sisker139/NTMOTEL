// screens/profile_screen.dart
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bảng tin")),
      body: const Center(child: Text("Nội dung bảng tin")),
    );
  }
}
