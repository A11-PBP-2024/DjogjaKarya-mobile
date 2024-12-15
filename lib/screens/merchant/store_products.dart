// store_products.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '/models/product.dart';
import '/models/store_entry.dart';
import '/screens/products/widgets/product_card.dart';
import '/screens/products/edit_product_screen.dart';

class StoreProductsPage extends StatefulWidget {
  final StoreEntry store;
  final bool isAdmin;

  const StoreProductsPage({
    Key? key,
    required this.store,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<StoreProductsPage> createState() => _StoreProductsPageState();
}

class _StoreProductsPageState extends State<StoreProductsPage> {
  bool _isLoading = true;
  List<Product> _products = [];
  late final CookieRequest request;

  @override
  void initState() {
    super.initState();
    request = context.read<CookieRequest>();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await request.get(
        'http://localhost:8000/merchant/products-flutter/?toko=${Uri.encodeComponent(widget.store.fields.name)}',
      );

      if (response is Map<String, dynamic> && response.containsKey('products')) {
        setState(() {
          _products = (response['products'] as List)
              .map((productData) {
                return Product.fromJson({
                  'id': productData['pk'],
                  'name': productData['fields']['name'],
                  'kategori': productData['fields']['kategori'],
                  'harga': productData['fields']['harga'],
                  'toko': productData['fields']['toko'],
                  'image': productData['fields']['image'],
                });
              })
              .toList();
          _isLoading = false;
        });
      } else {
        print('Invalid response format: $response');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error fetching products: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(Product product) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      final response = await request.post(
        'http://localhost:8000/product/delete-product-flutter/${product.id}/',
        {},
      );

      if (response['status'] == 'success') {
        setState(() {
          _products.removeWhere((p) => p.id == product.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete product')),
        );
      }
    }
  }

  Future<void> _handleEdit(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    );

    // If edit was successful (result == true), refresh the products list
    if (result == true) {
      setState(() {
        _isLoading = true;
      });
      await fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
        title: Text(
          widget.store.fields.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada produk yang ditemukan untuk toko ini.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return ProductCard(
                        product: product,
                        isAdmin: widget.isAdmin,
                        onDelete: () => _handleDelete(product),
                        onEdit: () => _handleEdit(product),
                      );
                    },
                  ),
                ),
    );
  }
}