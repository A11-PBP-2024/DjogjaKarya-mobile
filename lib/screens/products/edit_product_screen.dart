import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '/models/product.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  
  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String? _kategori;
  late int _harga;
  late String? _toko;
  late String _image;
  
  List<String> categories = [];
  List<String> stores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _kategori = widget.product.kategori;
    _harga = widget.product.harga;
    _toko = widget.product.toko;
    _image = widget.product.image;
    fetchFormData();
  }

  Future<void> fetchFormData() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'http://localhost:8000/product/get-form-data/'
      );
      setState(() {
        categories = List<String>.from(response['categories']);
        stores = List<String>.from(response['stores']);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching form data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Product'),
          backgroundColor: Colors.brown[700],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.brown[700],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  hintText: 'Enter product name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => setState(() => _name = value),
                validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: InputDecoration(
                  hintText: 'Select category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _kategori = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Price',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _harga.toString(),
                decoration: InputDecoration(
                  hintText: 'Enter price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => _harga = int.tryParse(value) ?? 0),
                validator: (value) => value?.isEmpty ?? true ? 'Price is required' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Store',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _toko,
                decoration: InputDecoration(
                  hintText: 'Select store',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: stores.map((String store) {
                  return DropdownMenuItem(
                    value: store,
                    child: Text(store),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _toko = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a store' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Image URL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _image,
                decoration: InputDecoration(
                  hintText: 'Enter image URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => setState(() => _image = value),
                validator: (value) => value?.isEmpty ?? true ? 'Image URL is required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final response = await request.post(
                          "http://localhost:8000/product/edit-product-flutter/${widget.product.id}/",
                          {
                            'name': _name,
                            'kategori': _kategori,
                            'harga': _harga.toString(),
                            'toko': _toko,
                            'image': _image,
                          },
                        );

                        if (response['status'] == 'success' && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Product updated successfully")),
                          );
                          Navigator.pop(context, true);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Update Product',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}