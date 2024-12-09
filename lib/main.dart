import 'package:flutter/material.dart';
import 'products/services/api_service.dart';
import 'products/screens/home_screen.dart';
import 'products/screens/categories_screen.dart'; 

void main() {
  // Adjust baseUrl to your Django server address (e.g. "http://10.0.2.2:8000" for Android emulator)
  final apiService = ApiService(baseUrl: "http://localhost:8000");
  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({Key? key, required this.apiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Produk Kerajinan',
      theme: ThemeData(primarySwatch: Colors.orange,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      
      ),
      home: CategoriesScreen(),
    );
  }
}
