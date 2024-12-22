// lib/services/review_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/review.dart';

class ReviewService {
 static const String baseUrl = "http://localhost:8000/reviews";

 Future<List<Review>> fetchReviews({required int productId}) async {
   try {
     final uri = Uri.parse("$baseUrl/api/reviews/").replace(
       queryParameters: {'product_id': productId.toString()},
     );
     
     final response = await http.get(uri);

     if (response.statusCode == 200) {
       List<dynamic> jsonResponse = json.decode(response.body);
       return jsonResponse.map((data) => Review.fromJson(data)).toList();
     } else {
       throw Exception("Failed to load reviews: ${response.statusCode}");
     }
   } catch (e) {
     throw Exception("Failed to load reviews: $e");
   }
 }

 Future<Review> addReview(Review review) async {
   try {
     final response = await http.post(
       Uri.parse("$baseUrl/api/reviews/add/"),
       headers: {
         'Content-Type': 'application/json',
       },
       body: jsonEncode(review.toJson()),
     );

     if (response.statusCode == 201) {
       return Review.fromJson(jsonDecode(response.body));
     } else {
       throw Exception("Failed to add review: ${response.statusCode}");
     }
   } catch (e) {
     throw Exception("Failed to add review: $e");
   }
 }
}