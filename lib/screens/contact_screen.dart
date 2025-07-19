// screens/profile_screen.dart
import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liên Hệ")),
      body: const Center(child: Text("Nội dung liên hệ")),
    );
  }
}
