import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '/screens/products/edit_product_screen.dart';
import '/services/api_service.dart';
import '/screens/products/widgets/product_card.dart';
import '/services/wishlist_service.dart'; 

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool isAdmin;
  final Function()? onEdit;

  const ProductDetailScreen({
    Key? key,
    required this.product,
    this.isAdmin = false,
    this.onEdit,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isInWishlist = false;
  List<Product> similarProducts = [];
  bool isLoading = true;
  final ApiService apiService = ApiService(baseUrl: "http://10.0.2.2:8000");
  late WishlistService wishlistService;
  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    final sessionId = request.cookies['sessionid'];
    final csrfToken = request.cookies['csrftoken'];
    wishlistService = WishlistService(baseUrl: "http://10.0.2.2:8000", token: csrfToken!.value,sessionid: sessionId!.value);

    _checkWishlistStatus();
    _loadSimilarProducts();
  }

  Future<void> _checkWishlistStatus() async {
  try {
    final wishlistItems = await wishlistService.fetchWishlist();
    setState(() {
      isInWishlist = wishlistItems.any((wl) => wl.product == widget.product.id);
    });
  } catch (e) {
    // Handle error if needed
  }
}

  Future<void> _loadSimilarProducts() async {
    try {
      final products = await apiService.fetchProducts(
        kategori: widget.product.kategori,
      );
      
      final filteredProducts = products
          .where((p) => p.id != widget.product.id)
          .toList()
        ..shuffle();
      
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
      (Match m) => '${m[1]}.'
    );
  }

void toggleWishlist() async {
  // setState(() {
  //   // Sementara setel status ke status kebalikan sebelum API selesai
  //   isInWishlist = !isInWishlist;
  // });

  try {
    if (!isInWishlist) {
      //klo isInWishlist == false = belum ada di wishlist brrti ditambahin
      final success = await wishlistService.addToWishlist(widget.product.id);
      if (!success) throw Exception('Failed to add to wishlist');
      setState(() {
        isInWishlist = true;
      });
    } else {
      //klo isInWishlist == true = sudah ada di wishlist brrti dihapus
      final success = await wishlistService.removeFromWishlist(widget.product.id);
      if (!success) throw Exception('Failed to remove from wishlist');
      setState(() {
        isInWishlist = false;
      });
    }
  } catch (e) {
    // Kembalikan status jika gagal
    // setState(() {
    //   isInWishlist = !isInWishlist; // Rollback if the operation fails
    // });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update wishlist')),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isInWishlist ? 'Added to wishlist' : 'Removed from wishlist',
      ),
      duration: const Duration(seconds: 1),
    ),
  );
}



  Future<void> _handleEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: widget.product),
      ),
    );

    if (result == true && mounted) {
      if (widget.onEdit != null) {
        widget.onEdit!();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product updated successfully")),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        print("widget.isAdmin");
        print(widget.isAdmin);

        Navigator.pop(context, false);
      },
      child: Scaffold(
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              size: 24,
                              color: Colors.grey[400],
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(0)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      
              // Similar Products Section
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
                      onDelete: () {}, // Empty callback since it's not needed for similar products
                      onEdit: () {}, // Empty callback since it's not needed for similar products
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: Container(
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
              child: widget.isAdmin
                ? ElevatedButton(
                    onPressed: _handleEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Edit Product',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton(
        onPressed: toggleWishlist,
        style: ElevatedButton.styleFrom(
      backgroundColor: isInWishlist ? Colors.grey[300] : Colors.brown[700],
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
        ),
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isInWishlist ? Icons.favorite : Icons.favorite_outline,
          color: isInWishlist ? Colors.red : Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          isInWishlist ? 'Added to Wishlist' : 'Add to Wishlist',
          style: TextStyle(
            color: isInWishlist ? Colors.black87 : Colors.white,
          ),
        ),
      ],
        ),
      ),
        ),
        ),
        ),
        ),
    );
  }
}