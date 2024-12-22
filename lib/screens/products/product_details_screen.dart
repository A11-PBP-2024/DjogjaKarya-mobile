import 'package:flutter/material.dart';
import '/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/services/api_service.dart';
import '/screens/products/widgets/product_card.dart';
import '/screens/review/review_list.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool isAdmin;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isAdmin = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isInWishlist = false;
  List<Product> similarProducts = [];
  bool isLoading = true;
  final ApiService apiService = ApiService(baseUrl: "https://fauzan-putra31-djogjakarya1.pbp.cs.ui.ac.id");

  @override
  void initState() {
    super.initState();
    _loadSimilarProducts();
  }

  Future<void> _loadSimilarProducts() async {
    try {
      final products = await apiService.fetchProducts(
        kategori: widget.product.kategori,
      );

      final filteredProducts =
          products.where((p) => p.id != widget.product.id).toList()..shuffle();

      setState(() {
        similarProducts = filteredProducts.take(5).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatPrice(int price) {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return price.toString().replaceAllMapped(
          formatter,
          (Match m) => '${m[1]}.',
        );
  }

  void toggleWishlist() {
    setState(() {
      isInWishlist = !isInWishlist;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isInWishlist ? 'Added to wishlist' : 'Removed from wishlist',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: widget.product.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Price:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp${formatPrice(widget.product.harga)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Available at:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.toko,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Review',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewListPage(
                              productId: widget.product.id,
                              productName: widget.product.name,
                              isAdmin: widget.isAdmin,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        backgroundColor: const Color(0xFFF3A73B),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "See Reviews",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (similarProducts.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Similar Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: similarProducts.length,
                  itemBuilder: (context, index) => ProductCard(
                    product: similarProducts[index],
                    isAdmin: widget.isAdmin,
                    onDelete: () {},
                    onEdit: () {},
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: !widget.isAdmin
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: toggleWishlist,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isInWishlist ? Colors.grey[300] : Colors.brown[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isInWishlist
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: isInWishlist ? Colors.red : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isInWishlist
                              ? 'Added to Wishlist'
                              : 'Add to Wishlist',
                          style: TextStyle(
                            color: isInWishlist ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
