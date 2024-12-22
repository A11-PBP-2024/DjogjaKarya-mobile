import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '/models/product.dart';
import '/services/api_service.dart';
import '/screens/products/widgets/product_card.dart';
import '/screens/products/add_product_screen.dart';
import '/screens/products/edit_product_screen.dart';
import 'package:provider/provider.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;
  final bool isAdmin;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    required this.isAdmin,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String? selectedAlphabetSort;
  String? selectedPriceSort;
  TextEditingController searchController = TextEditingController();
  final ApiService apiService = ApiService(baseUrl: "https://fauzan-putra31-djogjakarya1.pbp.cs.ui.ac.id");

  final List<String> alphabetSortOptions = ['A-Z', 'Z-A'];
  final List<String> priceSortOptions = ['Lowest Price', 'Highest Price'];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    try {
      final fetchedProducts =
          await apiService.fetchProducts(kategori: widget.categoryName);
      setState(() {
        products = fetchedProducts;
        filteredProducts = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applySorting() {
    setState(() {
      if (selectedAlphabetSort != null) {
        switch (selectedAlphabetSort) {
          case 'A-Z':
            filteredProducts.sort((a, b) => a.name.compareTo(b.name));
            break;
          case 'Z-A':
            filteredProducts.sort((a, b) => b.name.compareTo(a.name));
            break;
        }
      }

      if (selectedPriceSort != null) {
        switch (selectedPriceSort) {
          case 'Highest Price':
            filteredProducts.sort((a, b) => b.harga.compareTo(a.harga));
            break;
          case 'Lowest Price':
            filteredProducts.sort((a, b) => a.harga.compareTo(b.harga));
            break;
        }
      }
    });
  }

  void _applyFilters() {
    List<Product> result = List.from(products);

    if (searchController.text.isNotEmpty) {
      result = result
          .where((product) => product.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredProducts = result;
    });

    if (selectedAlphabetSort != null || selectedPriceSort != null) {
      _applySorting();
    }
  }

  void _clearFilters() {
    setState(() {
      searchController.clear();
      selectedAlphabetSort = null;
      selectedPriceSort = null;
      filteredProducts = List.from(products);
    });
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (_) => _applyFilters(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedAlphabetSort,
                  decoration: InputDecoration(
                    labelText: 'Sort by Alphabet',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('None'),
                    ),
                    ...alphabetSortOptions.map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedAlphabetSort = value;
                      selectedPriceSort = null;
                    });
                    if (value != null) _applySorting();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedPriceSort,
                  decoration: InputDecoration(
                    labelText: 'Sort by Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('None'),
                    ),
                    ...priceSortOptions.map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPriceSort = value;
                      selectedAlphabetSort = null;
                    });
                    if (value != null) _applySorting();
                  },
                ),
              ),
            ],
          ),
          if (searchController.text.isNotEmpty ||
              selectedAlphabetSort != null ||
              selectedPriceSort != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('Clear filters'),
                onPressed: _clearFilters,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onDeleteProduct(Product product) async {
    final request = context.read<CookieRequest>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          "Confirmation",
          style: TextStyle(color: Colors.brown[700]),
        ),
        content: Text("Are you sure want to delete ${product.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("No", style: TextStyle(color: Colors.brown[700])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Yes", style: TextStyle(color: Colors.brown[700])),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await request.post(
          "https://fauzan-putra31-djogjakarya1.pbp.cs.ui.ac.id/product/delete-product-flutter/${product.id}/",
          {}, // empty body karena delete
        );

        if (response['message'] != null) {
          // atau sesuaikan dengan response dari Django
          setState(() {
            products.remove(product);
            _applyFilters();
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Product deleted successfully")),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting product: $e")),
          );
        }
      }
    }
  }

  Future<void> _onEditProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    );

    if (result == true) {
      _fetchProducts();
    }
  }

  Future<void> _onAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );

    if (result == true) {
      _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.categoryName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Column(
        children: [
          if (widget.isAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _onAddProduct,
                ),
              ),
            ),
          _buildFilters(),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      "No products found with current filters",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        isAdmin: widget.isAdmin,
                        onEdit: () => _onEditProduct(product),
                        onDelete: () => _onDeleteProduct(product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
