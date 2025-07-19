// screens/profile_screen.dart
import 'package:flutter/material.dart';

class HometabScreen extends StatelessWidget {
  const HometabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        toolbarHeight: 120,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo ở giữa
            Center(
              child: SizedBox(
                height: 50,
                child: Image.asset(
                  'assets/logo2.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Thanh tìm kiếm + icon
            Row(
              children: [
                // Thanh tìm kiếm (dãn ra giữa)
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Text("Tìm kiếm", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Icon chat
                const Icon(Icons.chat_outlined, color: Colors.white),
                const SizedBox(width: 10),

                // Icon thông báo
                const Icon(Icons.notifications_outlined, color: Colors.white),
              ],
            ),
          ],
        ),
      ),


    );
  }
}
