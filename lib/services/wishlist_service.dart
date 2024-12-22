import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shop/models/product.dart';
import 'package:shop/models/wishlist_item.dart';

class WishlistService {
  final String baseUrl;
  final String token;
  final String sessionid;

  WishlistService(
      {required this.baseUrl, required this.token, this.sessionid = ""});

  Future<bool> addToWishlist(int productId) async {
    final url = Uri.parse('$baseUrl/wishlist/api/add/$productId/');
    final response = await http.post(
      url,
      headers: {
        'X-CSRFToken': token,
        'Cookie': 'csrftoken=$token;sessionid=$sessionid',
      },
    );
    return response.statusCode == 201;
  }

  Future<bool> removeFromWishlist(int productId) async {
    final url = Uri.parse('$baseUrl/wishlist/api/remove/$productId/');
    final response = await http.delete(
      url,
      headers: {
        'X-CSRFToken': token,
        'Cookie': 'csrftoken=$token;sessionid=$sessionid',
      },
    );

    return response.statusCode == 200;
  }

  Future<List<WishlistItem>> fetchWishlist() async {
    final url = Uri.parse('$baseUrl/wishlist/api/');
    final response = await http.get(url, headers: {
      'Cookie': 'sessionid=$sessionid',
    });
  // print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final wishlistList = List<WishlistItem>.from(
        json
            .decode(data['wishlist'])
            .map((item) => WishlistItem.fromJson(item)),
      );
      return wishlistList;
    } else {
      throw Exception('Failed to load wishlist');
    }
  }

  Future<Product> getByProductId(int id) async {
    final url = Uri.parse('$baseUrl/product/product/$id/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      var result = Product.fromJson(data);
      return result;
    } else {
      throw Exception('Failed to load products');
    }
  }
}
