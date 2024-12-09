import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/auth/auth_controller.dart';
import 'screens/auth/views/login_page.dart';
import 'screens/auth/views/register_page.dart';

void main() {
  // Initialize AuthController
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Menggunakan GetMaterialApp instead of MaterialApp
      title: 'Djogjakarya',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login', // Set initial route ke halaman login
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegisterPage()),
        // Tambahkan route lain di sini
      ],
    );
  }
}