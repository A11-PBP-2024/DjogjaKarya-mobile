// lib/src/models/category_item.dart
class CategoryItem {
  final String name;
  final String imageUrl;

  CategoryItem({required this.name, required this.imageUrl});

  // Jika nanti ambil dari JSON:
  // factory CategoryItem.fromJson(Map<String, dynamic> json) {
  //   return CategoryItem(
  //     name: json['name'],
  //     imageUrl: json['image'],
  //   );
  // }
}
