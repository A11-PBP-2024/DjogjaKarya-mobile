import 'package:flutter/material.dart';
import '../../services/review_service.dart';
import '../../models/review.dart';

class AddReviewPage extends StatefulWidget {
  final int productId;
  final String productName;

  const AddReviewPage({
    Key? key, 
    required this.productId,
    required this.productName,
  }) : super(key: key);

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final ReviewService _reviewService = ReviewService();
  int _selectedRating = 0;

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate() && _selectedRating > 0) {
      try {
        final review = Review(
          product: widget.productId,
          rating: _selectedRating,
          comment: _commentController.text,
          createdAt: DateTime.now(),
        );

        await _reviewService.addReview(review);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review added successfully!')),
          );
          Navigator.pop(context, true); // true indicates success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add review: $e')),
          );
        }
      }
    } else if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRating = starNumber;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starNumber <= _selectedRating ? Icons.star : Icons.star_border,
              color: starNumber <= _selectedRating ? Colors.amber : Colors.grey[300],
              size: 40,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Review'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                'Add a Review for ${widget.productName}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Review Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating Section
                      const Text(
                        'Rating (1-5)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStarRating(),
                      const Center(
                        child: Text(
                          'Choose your rating by selecting stars from 1 to 5',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Comment Section
                      const Text(
                        'Your Review',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write your review here...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFF3A73B)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your review';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3A73B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 4,
                          ).copyWith(
                            overlayColor: MaterialStateProperty.resolveWith(
                              (states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return const Color(0xFFF3A73B).withOpacity(0.8);
                                }
                                return null;
                              },
                            ),
                          ),
                          child: const Text(
                            'Submit Review',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}