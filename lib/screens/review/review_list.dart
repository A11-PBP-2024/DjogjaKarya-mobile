import 'package:flutter/material.dart';
import '../../services/review_service.dart';
import '../../models/review.dart';
import '../review/add_review.dart';
import 'package:intl/intl.dart';

class ReviewListPage extends StatefulWidget {
  final int productId;
  final String productName;
  final bool isAdmin;

  const ReviewListPage({
    Key? key,
    required this.productId,
    required this.productName,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  late Future<List<Review>> futureReviews;
  final ReviewService _reviewService = ReviewService();
  double _averageRating = 0.0;
  int _totalReviews = 0;
  Map<int, int> _starSummary = {};

  @override
  void initState() {
    super.initState();
    futureReviews = _fetchReviewsAndSummary();
  }

  Future<List<Review>> _fetchReviewsAndSummary() async {
    final reviews = await _reviewService.fetchReviews(productId: widget.productId);
    _calculateSummary(reviews);
    return reviews;
  }

  Future<void> _deleteReview(int reviewId) async {
    try {
      final success = await _reviewService.deleteReview(reviewId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ulasan berhasil dihapus')),
          );
          setState(() {
            futureReviews = _fetchReviewsAndSummary();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus ulasan: $e')),
        );
      }
    }
  }

  void _calculateSummary(List<Review> reviews) {
    _totalReviews = reviews.length;
    if (_totalReviews > 0) {
      double totalRating = 0;
      _starSummary = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (var review in reviews) {
        totalRating += review.rating;
        _starSummary[review.rating] = (_starSummary[review.rating] ?? 0) + 1;
      }

      setState(() {
        _averageRating = totalRating / _totalReviews;
      });
    }
  }

  Widget _buildStars(double rating, {double size = 24}) {
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

  Widget _buildSummaryBar(int star, int count) {
    double percentage = _totalReviews > 0 ? (count / _totalReviews) * 100 : 0;
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
        title: const Text('Ulasan Pelanggan & Peringkat'),
      ),
      body: FutureBuilder<List<Review>>(
        future: futureReviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final reviews = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('$_totalReviews Ulasan'),
                      const SizedBox(height: 8),
                      _buildStars(_averageRating),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ringkasan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ..._starSummary.entries
                    .toList()
                    .reversed
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildSummaryBar(e.key, e.value),
                        )),
                const SizedBox(height: 24),
                const Text(
                  'Ulasan Pelanggan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (reviews.isEmpty)
                  const Center(
                    child: Text('Tidak ada ulasan untuk produk ini.'),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        _buildStars(review.rating.toDouble(), size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('MMM d, y').format(review.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (widget.isAdmin)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.grey,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Hapus Ulasan'),
                                            content: const Text('Apakah Anda yakin ingin menghapus ulasan ini?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Batal'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteReview(review.id!);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Hapus'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
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
                          if (value == true) {
                            setState(() {
                              futureReviews = _fetchReviewsAndSummary();
                            });
                          }
                        });
                      },
                      child: const Text(
                        'Tambah Ulasan',
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