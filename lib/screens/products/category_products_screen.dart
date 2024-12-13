
import 'package:flutter/material.dart';
import '/models/product.dart';
import '/services/api_service.dart';
import '/screens/products/widgets/product_card.dart';
import '/screens/products/add_product_screen.dart';
import '/screens/products/edit_product_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;
  final bool isAdmin;

  const CategoryProductsScreen({
    Key? key,
    required this.categoryName,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String? selectedLetter;
  String? selectedPriceRange;
  TextEditingController searchController = TextEditingController();
  final ApiService apiService = ApiService(baseUrl: "http://localhost:8000");

  // Simplified price ranges
  final List<String> priceRanges = [
    'Murah',     // Cheaper options
    'Sedang',    // Mid-range
    'Mahal',     // Expensive
  ];

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
      final fetchedProducts = await apiService.fetchProducts(kategori: widget.categoryName);
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

  void _applyFilters() {
    List<Product> result = List.from(products);

    // Apply text search filter
    if (searchController.text.isNotEmpty) {
      result = result.where((product) => 
        product.name.toLowerCase().contains(searchController.text.toLowerCase())
      ).toList();
    }

    // Apply letter filter
    if (selectedLetter != null) {
      result = result.where((product) => 
        product.name.toUpperCase().startsWith(selectedLetter!)
      ).toList();
    }

    // Apply simplified price filter
    if (selectedPriceRange != null) {
      // Sort products by price to determine ranges
      final sortedProducts = List.from(products);
      sortedProducts.sort((a, b) => a.price.compareTo(b.price));
      
      final int totalProducts = sortedProducts.length;
      final int rangeSize = (totalProducts / 3).ceil();

      result = result.where((product) {
        final index = sortedProducts.indexOf(product);
        switch (selectedPriceRange) {
          case 'Murah':
            return index < rangeSize;
          case 'Sedang':
            return index >= rangeSize && index < rangeSize * 2;
          case 'Mahal':
            return index >= rangeSize * 2;
          default:
            return true;
        }
      }).toList();
    }

    setState(() {
      filteredProducts = result;
    });
  }

  void _clearFilters() {
    setState(() {
      searchController.clear();
      selectedLetter = null;
      selectedPriceRange = null;
      filteredProducts = products;
    });
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search TextField
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (_) => _applyFilters(),
          ),
          SizedBox(height: 16),
          
          // Dropdowns row
          Row(
            children: [
              // Alphabet dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedLetter,
                  decoration: InputDecoration(
                    labelText: 'Filter by letter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('All letters'),
                    ),
                    ...List.generate(26, (index) => 
                      DropdownMenuItem(
                        value: String.fromCharCode(65 + index),
                        child: Text(String.fromCharCode(65 + index)),
                      )
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedLetter = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              SizedBox(width: 16),
              // Simplified price range dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedPriceRange,
                  decoration: InputDecoration(
                    labelText: 'Filter by price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('All prices'),
                    ),
                    ...priceRanges.map((range) => DropdownMenuItem(
                      value: range,
                      child: Text(range),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPriceRange = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          
          // Clear filters button
          if (searchController.text.isNotEmpty || 
              selectedLetter != null || 
              selectedPriceRange != null)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: TextButton.icon(
                icon: Icon(Icons.clear),
                label: Text('Clear all filters'),
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
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmation"),
        content: Text("Are you sure want to delete ${product.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await apiService.deleteProduct(product.id);
      if (success) {
        setState(() {
          products.remove(product);
          _applyFilters();
        });
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
        builder: (context) => AddProductScreen(),
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
        body: Center(child: CircularProgressIndicator()),
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
                  icon: Icon(Icons.add),
                  label: Text('Add Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    padding: EdgeInsets.symmetric(vertical: 12),
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
                ? Center(
                    child: Text(
                      "No products found with current filters",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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