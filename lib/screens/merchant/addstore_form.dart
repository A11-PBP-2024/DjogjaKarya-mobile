import 'dart:convert';

import '/screens/merchant/store_list.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class StoreEntryFormPage extends StatefulWidget {
  const StoreEntryFormPage({super.key});

  @override
  State<StoreEntryFormPage> createState() => _StoreEntryFormPageState();
}

class _StoreEntryFormPageState extends State<StoreEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _description = "";
  String _address = "";
  String _opening_days = "";
  String _opening_hours = "";
  String _phone = "";
  Uri? _image1;
  Uri? _image2;
  Uri? _image3;
  Uri? _location_link;

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
        title: const Center(
          child: Text(
            'Add Store',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.brown[700],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Regular text fields remain the same
              _buildTextField(
                "Name",
                (value) => setState(() => _name = value ?? ''),
                (value) => value == null || value.isEmpty ? "Name tidak boleh kosong!" : null,
              ),
              _buildTextField(
                "Description",
                (value) => setState(() => _description = value ?? ''),
                (value) => value == null || value.isEmpty ? "Description tidak boleh kosong!" : null,
                maxLines: 3,
              ),
              _buildTextField(
                "Address",
                (value) => setState(() => _address = value ?? ''),
                (value) => value == null || value.isEmpty ? "Address tidak boleh kosong!" : null,
              ),
              _buildTextField(
                "Opening Days",
                (value) => setState(() => _opening_days = value ?? ''),
                (value) => value == null || value.isEmpty ? "Opening days tidak boleh kosong!" : null,
              ),
              _buildTextField(
                "Opening Hours",
                (value) => setState(() => _opening_hours = value ?? ''),
                (value) => value == null || value.isEmpty ? "Opening hours tidak boleh kosong!" : null,
              ),
              _buildTextField(
                "Phone",
                (value) => setState(() => _phone = value ?? ''),
                (value) => value == null || value.isEmpty ? "Phone tidak boleh kosong!" : null,
              ),

              // URL fields with proper handling
              _buildTextField(
                "Image 1 URL",
                (value) => setState(() {
                  _image1 = value != null && value.isNotEmpty ? Uri.parse(value) : null;
                }),
                (value) => _validateUrl(value, "Image 1"),
              ),
              _buildTextField(
                "Image 2 URL",
                (value) => setState(() {
                  _image2 = value != null && value.isNotEmpty ? Uri.parse(value) : null;
                }),
                (value) => _validateUrl(value, "Image 2"),
              ),
              _buildTextField(
                "Image 3 URL",
                (value) => setState(() {
                  _image3 = value != null && value.isNotEmpty ? Uri.parse(value) : null;
                }),
                (value) => _validateUrl(value, "Image 3"),
              ),
              _buildTextField(
                "Location Link URL",
                (value) => setState(() {
                  _location_link = value != null && value.isNotEmpty ? Uri.parse(value) : null;
                }),
                (value) => _validateUrl(value, "Location link"),
              ),

              // Save Button
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                            // Kirim ke Django dan tunggu respons
                            final response = await request.postJson(
                                "http://localhost:8000/merchant/create-flutter/",
                                jsonEncode(<String, String>{
                                    'name': _name,
                                    'description': _description,
                                    'address': _address,
                                    'opening_days': _opening_days,
                                    'opening_hours': _opening_hours,
                                    'phone': _phone,
                                    'image1': _image1.toString(),
                                    'image2': _image2.toString(),
                                    'image3': _image3.toString(),
                                    'location_link': _location_link.toString(),
                                }),
                            );
                            if (context.mounted) {
                                if (response['status'] == 'success') {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                    content: Text("Store baru berhasil disimpan!"),
                                    ));
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const StoreEntryPage()),
                                    );
                                } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                        content:
                                            Text("Terdapat kesalahan, silakan coba lagi."),
                                    ));
                                }
                            }
                        }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
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
    Function(String?) onChanged,
    String? Function(String?) validator, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: label,
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}