import 'package:flutter/material.dart';
import '/models/article.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class EditArticleFormPage extends StatefulWidget {
  final Article article;

  const EditArticleFormPage({super.key, required this.article});

  @override
  _EditArticleFormPageState createState() => _EditArticleFormPageState();
}

class _EditArticleFormPageState extends State<EditArticleFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _content;
  late String _tags;
  late String _image;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _title = widget.article.title;
    _description = widget.article.description;
    _content = widget.article.content;
    _tags = widget.article.tags;
    _image = widget.article.image;
  }

  Future<void> editArticle() async {
    final request = context.read<CookieRequest>();

    setState(() {
      isLoading = true;
    });

    final response = await request.post(
      'http://127.0.0.1:8000/article/edit-article-flutter/${widget.article.id}/',
      jsonEncode({
        'title': _title,
        'description': _description,
        'content': _content,
        'tags': _tags,
        'image': _image,
      }),
    );

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article updated successfully!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Failed to update article.'),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Article'),
        backgroundColor: Colors.blue[800],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _title,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _title = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Title cannot be empty' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _description = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _content,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _content = value,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _tags,
                      decoration: const InputDecoration(
                        labelText: 'Tags',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _tags = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _image,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _image = value,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          editArticle();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
