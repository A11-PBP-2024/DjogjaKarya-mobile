// category_products_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart'; 
import '../services/api_service.dart';  // Pastikan anda punya API service yang bisa fetch produk by kategori
import '../widgets/product_card.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryProductsScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> products = [];
  bool isLoading = true;
  final ApiService apiService = ApiService(baseUrl: "http://localhost:8000"); // Ubah sesuai URL Django anda

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      // Asumsikan apiService.fetchProducts(kategori: ...) sudah diimplementasi
      final fetchedProducts = await apiService.fetchProducts(kategori: widget.categoryName);
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(child: Text("No products found in this category."))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(product: product);
                  },
                ),
    );
  }
}
