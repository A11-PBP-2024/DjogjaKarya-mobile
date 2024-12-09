// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<Product>> fetchProducts({String? kategori}) async {
    final uri = Uri.parse("$baseUrl/product/filter-kategori/?kategori=${kategori ?? 'all'}");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      if (kategori != null && kategori.toLowerCase() != 'all') {
        // Jika kategori spesifik, data ada di 'products'
        if (jsonData['products'] is List) {
          return (jsonData['products'] as List)
              .map((item) => Product.fromJson(item))
              .toList();
        }
        return [];
      } else {
        // Jika kategori = all, data terpisah per kategori. 
        // Mungkin tidak digunakan disini, 
        // tapi jika perlu gabungkan semua
        List<Product> combined = [];
        jsonData.forEach((key, value) {
          if (value is List) {
            combined.addAll(value.map((item) => Product.fromJson(item)).toList());
          }
        });
        return combined;
      }
    } else {
      throw Exception("Failed to load products");
    }
  }
}
