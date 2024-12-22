import 'package:flutter/material.dart';
import '/models/article.dart';
import 'widgets/article_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/article/add_article.dart';

class BlogHomePage extends StatefulWidget {
  final bool isAdmin;

  const BlogHomePage({super.key, this.isAdmin = false});

  @override
  State<BlogHomePage> createState() => _BlogHomePageState();
}

class _BlogHomePageState extends State<BlogHomePage> {
  String _searchQuery = '';
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  late final CookieRequest request;

  @override
  void initState() {
    super.initState();
    request = context.read<CookieRequest>();
    _fetchInitialData();
  }

  /// Fetch Data Artikel dan Status Admin
  Future<void> _fetchInitialData() async {
    try {
      // Fetch status admin
      final userResponse =
          await request.get('https://fauzan-putra31-djogjakarya1.pbp.cs.ui.ac.id/article/get-user-status/');
      setState(() {
        _isAdmin = userResponse['is_admin'] ?? false;
      });

      // Fetch artikel
      await fetchArticles(request);
    } catch (e) {
      print('Error fetching initial data: $e');
    }
  }

  /// Fetch Artikel dari Django
  Future<void> fetchArticles(CookieRequest request) async {
    try {
      final response =
          await request.get('https://fauzan-putra31-djogjakarya1.pbp.cs.ui.ac.id/article/get-articles/');
      setState(() {
        _allArticles = [];
        for (var d in response) {
          if (d != null) {
            _allArticles.add(Article.fromJson(d));
          }
        }
        _filteredArticles = List.from(_allArticles);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching articles: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Filter Artikel Berdasarkan Query
  void _filterArticles(String query) {
    setState(() {
      _searchQuery = query;
      _filteredArticles = _allArticles
          .where((article) =>
              article.title.toLowerCase().contains(query.toLowerCase()) ||
              article.tags.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// Tombol Tambah Artikel
  Widget _buildAddButton() {
    if (!_isAdmin) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          onPressed: () async {
            final newArticle = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddArticleFormPage(),
              ),
            );

            if (newArticle != null && newArticle is Article) {
              setState(() {
                _allArticles.add(newArticle);
                _filterArticles(_searchQuery); // Refresh list
              });
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Article'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Articles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAddButton(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildArticleList(),
          ),
        ],
      ),
    );
  }

  /// Menampilkan Daftar Artikel
  Widget _buildArticleList() {
    if (_allArticles.isEmpty) {
      return Center(
        child: Text(
          'No articles available.',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: _filterArticles,
              decoration: InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Found ${_filteredArticles.length} article(s)',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _filteredArticles.length,
            itemBuilder: (_, index) => ArticleCard(
              article: _filteredArticles[index],
              onDeleteSuccess: _fetchInitialData,
              isAdmin: _isAdmin,
            ),
          ),
        ),
      ],
    );
  }
}
