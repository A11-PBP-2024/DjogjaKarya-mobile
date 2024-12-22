import 'package:flutter/material.dart';
import '/models/article.dart';
import 'package:shop/screens/article/article_detail.dart';

// Dummy data untuk simulasi artikel
final List<Article> articles = [
  Article(
    id: 1,
    title: "Exploring the Art of Batik",
    description: "Batik is a traditional fabric dyeing technique...",
    content: "Detailed content about Batik...",
    author: "John Doe",
    tags: "art, heritage",
    publicationDate: "2024-12-15",
    image: "https://example.com/batik.jpg",
  ),
  Article(
    id: 2,
    title: "Heritage Sites to Visit",
    description: "Discover the best heritage sites in Indonesia...",
    content: "Detailed content about heritage sites...",
    author: "Jane Smith",
    tags: "travel, heritage",
    publicationDate: "2024-11-10",
    image: "https://example.com/heritage.jpg",
  ),
];

class BlogHomePage extends StatelessWidget {
  const BlogHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search for articles",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Trending Articles",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArticleDetail(article: article),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      article.image,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "${article.author}, ${article.publicationDate}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: articles.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
