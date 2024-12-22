import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import '/models/store_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditStoreFormPage extends StatefulWidget {
  final StoreEntry store;

  const EditStoreFormPage({Key? key, required this.store}) : super(key: key);

  @override
  State<EditStoreFormPage> createState() => _EditStoreFormPageState();
}

class _EditStoreFormPageState extends State<EditStoreFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late String _address;
  late String _opening_days;
  late String _opening_hours;
  late String _phone;
  late String _image1;
  late String _image2;
  late String _image3;
  late String _location_link;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with existing store data
    _name = widget.store.fields.name;
    _description = widget.store.fields.description;
    _address = widget.store.fields.address;
    _opening_days = widget.store.fields.opening_days;
    _opening_hours = widget.store.fields.opening_hours;
    _phone = widget.store.fields.phone;
    _image1 = widget.store.fields.image1;
    _image2 = widget.store.fields.image2;
    _image3 = widget.store.fields.image3;
    _location_link = widget.store.fields.location_link;
  }

  String? _validateUrl(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName tidak boleh kosong!";
    }
    try {
      Uri.parse(value);
      return null;
    } catch (e) {
      return "URL tidak valid!";
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Store',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextField(
                "Name",
                _name,
                (value) => setState(() => _name = value ?? ''),
                (value) => value == null || value.isEmpty ? "Name tidak boleh kosong!" : null,
              ),
              _buildTextField(
                "Description",
                _description,
                (value) => setState(() => _description = value ?? ''),
                (value) => value == null || value.isEmpty ? "Description tidak boleh kosong!" : null,
                maxLines: 3,
              ),
              _buildTextField(
                "Address",
                _address,
                (value) => setState(() => _address = value ?? ''),
                (value) => value == null || value.isEmpty ? "Address tidak boleh kosong!" : null,
              ),
              _buildTextField(
                "Opening Days",
                _opening_days,
                (value) => setState(() => _opening_days = value ?? ''),
                (value) => value == null || value.isEmpty ? "Opening days tidak boleh kosong!" : null,
              ),
              _buildTextField(
                "Opening Hours",
                _opening_hours,
                (value) => setState(() => _opening_hours = value ?? ''),
                (value) => value == null || value.isEmpty ? "Opening hours tidak boleh kosong!" : null,
              ),
              _buildTextField(
                "Phone",
                _phone,
                (value) => setState(() => _phone = value ?? ''),
                (value) => value == null || value.isEmpty ? "Phone tidak boleh kosong!" : null,
              ),
              _buildTextField(
                "Image 1 URL",
                _image1,
                (value) => setState(() => _image1 = value ?? ''),
                (value) => _validateUrl(value, "Image 1"),
              ),
              _buildTextField(
                "Image 2 URL",
                _image2,
                (value) => setState(() => _image2 = value ?? ''),
                (value) => _validateUrl(value, "Image 2"),
              ),
              _buildTextField(
                "Image 3 URL",
                _image3,
                (value) => setState(() => _image3 = value ?? ''),
                (value) => _validateUrl(value, "Image 3"),
              ),
              _buildTextField(
                "Location Link URL",
                _location_link,
                (value) => setState(() => _location_link = value ?? ''),
                (value) => _validateUrl(value, "Location link"),
              ),
              const SizedBox(height: 20),
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
                      // Prepare data to be sent
                      final response = await request.post(
                        'http://localhost:8000/merchant/edit-flutter/${widget.store.pk}/',
                        jsonEncode({
                          'name': _name,
                          'description': _description,
                          'address': _address,
                          'opening_days': _opening_days,
                          'opening_hours': _opening_hours,
                          'phone': _phone,
                          'image1': _image1,
                          'image2': _image2,
                          'image3': _image3,
                          'location_link': _location_link,
                        }),
                      );
                      if (response['status'] == 'success') {
                        Navigator.pop(context); // Return to previous screen
                      }
                    }
                  },
                  child: const Text(
                    'Update Store',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String initialValue,
    Function(String?) onChanged,
    String? Function(String?) validator, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.brown[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.brown[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.brown[700]!),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}