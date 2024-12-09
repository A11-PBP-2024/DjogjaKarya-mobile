import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;

  const HomeScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  bool isLoading = true;
  String selectedKategori = "all";

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      setState(() {
        isLoading = true;
      });
      final fetchedProducts = await widget.apiService.fetchProducts(kategori: selectedKategori);
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

  void _onCategorySelected(String kategori) {
    setState(() {
      selectedKategori = kategori;
    });
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    // Example static categories
    final categories = ["all", "Batik", "Kerajinan Kulit", "Perak Kotagede", "Kerajinan Wayang"];

    return Scaffold(
      appBar: AppBar(
        title: Text("Produk Kerajinan"),
      ),
      body: Column(
        children: [
          // Simple Dropdown for categories
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedKategori,
              onChanged: (value) {
                if (value != null) {
                  _onCategorySelected(value);
                }
              },
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? Center(child: Text("No products found"))
                    : GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(product: product);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
