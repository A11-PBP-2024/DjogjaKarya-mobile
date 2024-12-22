class Review {
  int? id; // Nullable id
  int product;
  int rating;
  String comment;
  DateTime createdAt;

  Review({
    this.id, // Opsional
    required this.product,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"], // Tetap nullable
        product: json["product"],
        rating: json["rating"],
        comment: json["comment"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) "id": id, // Kirim id hanya jika tidak null
        "product": product,
        "rating": rating,
        "comment": comment,
        "created_at": createdAt.toIso8601String(),
      };
}
