
class WishlistItem {
  final int pk;
  final String user;
  final int product;

  WishlistItem({required this.pk,
    required this.user,
    required this.product,});

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      pk: json['pk'],
      user: json['fields']['user'][0],
      product: json['fields']['product'],
    );
  }
}
