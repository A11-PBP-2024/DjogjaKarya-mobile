import 'package:flutter/material.dart';
import '../../services/review_service.dart';
import '../../models/review.dart';
import '../review/add_review.dart';
import 'package:intl/intl.dart';

class ReviewListPage extends StatefulWidget {
  final int productId;
  final String productName;
  
  const ReviewListPage({
    Key? key, 
    required this.productId,
    required this.productName,
  }) : super(key: key);

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  late Future<List<Review>> futureReviews;
  final ReviewService reviewService = ReviewService();
  double averageRating = 0.0;
  int totalReviews = 0;
  Map<int, int> starSummary = {};

  @override
  void initState() {
    super.initState();
    futureReviews = fetchReviewsAndSummary();
  }

  Future<List<Review>> fetchReviewsAndSummary() async {
    final reviews = await reviewService.fetchReviews(productId: widget.productId);
    calculateSummary(reviews);
    return reviews;
  }

  void calculateSummary(List<Review> reviews) {
    totalReviews = reviews.length;
    if (totalReviews > 0) {
      double totalRating = 0;
      starSummary = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      
      for (var review in reviews) {
        totalRating += review.rating;
        starSummary[review.rating] = (starSummary[review.rating] ?? 0) + 1;
      }
      
      setState(() {
        averageRating = totalRating / totalReviews;
      });
    }
  }

  Widget buildStars(double rating, {double size = 24}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating) {
          return Icon(Icons.star, color: Colors.amber, size: size);
        } else if (index == rating.floor() && rating % 1 != 0) {
          return Icon(Icons.star_half, color: Colors.amber, size: size);
        }
        return Icon(Icons.star_border, color: Colors.grey, size: size);
      }),
    );
  }

  Widget buildSummaryBar(int star, int count) {
    double percentage = totalReviews > 0 ? (count / totalReviews) * 100 : 0;
    return Row(
      children: [
        Text('$star', style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        const Icon(Icons.star, color: Colors.amber, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3A73B),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$count', style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Reviews & Ratings'),
      ),
      body: FutureBuilder<List<Review>>(
        future: futureReviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reviews = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Average Rating Section
                Center(
                  child: Column(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('$totalReviews Ratings'),
                      const SizedBox(height: 8),
                      buildStars(averageRating),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Summary Section
                const Text(
                  'Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...starSummary.entries
                    .toList()
                    .reversed
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: buildSummaryBar(e.key, e.value),
                        )),

                const SizedBox(height: 24),

                // Reviews Section
                const Text(
                  'Customer Reviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (reviews.isEmpty)
                  const Center(
                    child: Text('There are no reviews for this product.'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  buildStars(review.rating.toDouble(), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('MMM d, y')
                                        .format(review.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(review.comment),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // Add Review Button
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3A73B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddReviewPage(
                              productId: widget.productId,
                              productName: widget.productName,
                            ),
                          ),
                        ).then((value) {
                          // Refresh halaman ketika kembali dari add review
                          if (value == true) {
                            setState(() {
                              futureReviews = fetchReviewsAndSummary();
                            });
                          }
                        });
                      },
                      child: const Text(
                        'Add Review',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}