// screens/profile_screen.dart
import 'package:flutter/material.dart';

class SaveScreen extends StatelessWidget {
  const SaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đã Lưu")),
      body: const Center(child: Text("Nội dung đã lưu")),
    );
  }
}
