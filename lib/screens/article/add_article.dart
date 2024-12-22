import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AddArticleScreen extends StatefulWidget {
  const AddArticleScreen({super.key});

  @override
  _AddArticleScreenState createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String content = '';
  String tags = '';
  String image = '';

  Future<void> addArticle() async {
    final response = await http.post(
      Uri.parse(
          'http://127.0.0.1:8000/article/add-article-flutter/'), // URL Django
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'content': content,
        'tags': tags,
        'image': image,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article added successfully!')),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add article.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => title = value,
                validator: (value) =>
                    value!.isEmpty ? 'Title cannot be empty' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Content'),
                onChanged: (value) => content = value,
                maxLines: 5,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tags'),
                onChanged: (value) => tags = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Image URL'),
                onChanged: (value) => image = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addArticle();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
