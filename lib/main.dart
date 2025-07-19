import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ntmotel/providers/auth_provider.dart';
import 'package:ntmotel/screens/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng MultiProvider nếu sau này có thêm nhiều provider khác
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'NTMotel',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // Trang chủ của ứng dụng bây giờ là AuthWrapper
        home: const AuthWrapper(),
      ),
    );
  }
}