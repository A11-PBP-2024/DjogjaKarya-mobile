
// product.dart (model)
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

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    kategori: json["kategori"],
    harga: json["harga"],
    toko: json["toko"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "kategori": kategori,
    "harga": harga,
    "toko": toko,
    "image": image,
  };
}