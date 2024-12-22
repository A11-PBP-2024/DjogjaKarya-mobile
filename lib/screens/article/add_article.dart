import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/article.dart';

class AddArticleFormPage extends StatefulWidget {
  const AddArticleFormPage({super.key});

  @override
  State<AddArticleFormPage> createState() => _AddArticleFormPageState();
}

class _AddArticleFormPageState extends State<AddArticleFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title = '';
  late String _description = '';
  late String _content = '';
  late String _tags = ''; // Untuk menyimpan tag yang dipilih
  late String _image = '';
  late String _author = '';

  final List<String> _tagOptions = [
    'Art',
    'Heritage',
    'Culture',
    'Craft',
    'Travel'
  ]; // Daftar pilihan tags

  Future<void> _addArticle() async {
    final response = await http.post(
      Uri.parse('https://fauzan-putra31-djogjakarya1.pbp.cs.ui.ac.id/article/add-article-flutter/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': _title,
        'description': _description,
        'content': _content,
        'tags': _tags, // Kirim tag yang dipilih
        'image': _image,
        'author': _author,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final newArticle = Article.fromJson(jsonResponse);

      Navigator.pop(context, newArticle);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add article')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => _title = value,
                validator: (value) =>
                    value!.isEmpty ? 'Title cannot be empty' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Author'),
                onChanged: (value) => _author = value,
                validator: (value) =>
                    value!.isEmpty ? 'Author cannot be empty' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => _description = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Content'),
                onChanged: (value) => _content = value,
                maxLines: 5,
              ),
              const SizedBox(height: 20),

              // Dropdown untuk memilih Tags
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  border: OutlineInputBorder(),
                ),
                value: _tags.isEmpty ? null : _tags,
                items: _tagOptions.map((String tag) {
                  return DropdownMenuItem<String>(
                    value: tag,
                    child: Text(tag),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tags = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a tag' : null,
              ),

              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Image URL'),
                onChanged: (value) => _image = value,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addArticle();
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
