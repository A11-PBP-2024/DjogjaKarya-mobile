import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '/models/article.dart';

class EditArticleScreen extends StatefulWidget {
  final Article article;

  const EditArticleScreen({super.key, required this.article});

  @override
  _EditArticleScreenState createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  late String content;
  late String tags;
  late String image;

  @override
  void initState() {
    super.initState();
    title = widget.article.title;
    description = widget.article.description;
    content = widget.article.content;
    tags = widget.article.tags;
    image = widget.article.image;
  }

  Future<void> editArticle() async {
    final response = await http.post(
      Uri.parse(
          'http://127.0.0.1:8000/article/edit-article-flutter/${widget.article.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'content': content,
        'tags': tags,
        'image': image,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article updated successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update article.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => title = value,
                validator: (value) =>
                    value!.isEmpty ? 'Title cannot be empty' : null,
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
              TextFormField(
                initialValue: content,
                decoration: const InputDecoration(labelText: 'Content'),
                onChanged: (value) => content = value,
                maxLines: 5,
              ),
              TextFormField(
                initialValue: tags,
                decoration: const InputDecoration(labelText: 'Tags'),
                onChanged: (value) => tags = value,
              ),
              TextFormField(
                initialValue: image,
                decoration: const InputDecoration(labelText: 'Image URL'),
                onChanged: (value) => image = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    editArticle();
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
