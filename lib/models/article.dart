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
  factory Article.fromJson(Map<String, dynamic> json) {
    final fields = json['fields'];
    return Article(
      id: json['pk'], // Ambil pk sebagai id
      title: fields['title'] ?? 'Untitled',
      description: fields['description'] ?? '',
      content: fields['content'] ?? '',
      author: fields['author'] ?? 'Unknown',
      tags: fields['tags'] ?? '',
      publicationDate: fields['publication_date'] ?? '',
      image: fields['image'] ?? '',
    );
  }

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
