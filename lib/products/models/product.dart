class Product {
  final int id;
  final String name;
  final String kategori;
  final int harga;
  final String toko;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.kategori,
    required this.harga,
    required this.toko,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      kategori: json['kategori'],
      harga: json['harga'],
      toko: json['toko'],
      image: json['image'],
    );
  }
}
