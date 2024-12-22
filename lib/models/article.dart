// article.dart (model)
class Article {
  final int id;
  final String title;
  final String description;
  final String content;
  final String author;
  final String tags;
  final String publicationDate;
  final String image;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.tags,
    required this.publicationDate,
    required this.image,
  });

  // Factory method untuk parsing dari JSON
  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        content: json["content"],
        author: json["author"],
        tags: json["tags"],
        publicationDate: json["publication_date"],
        image: json["image"] ?? '', // Handle jika image kosong
      );

  // Konversi dari objek ke JSON (untuk POST / PUT request)
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "content": content,
        "author": author,
        "tags": tags,
        "publication_date": publicationDate,
        "image": image,
      };
}
