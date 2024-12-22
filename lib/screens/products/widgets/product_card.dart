// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shop/services/wishlist_service.dart';
import '/models/product.dart';
import '/screens/products/product_details_screen.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool isAdmin;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ProductCard({
    Key? key,
    required this.product,
    required this.isAdmin,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late WishlistService wishlistService;

  bool isInWishlist = false; // Status wishlist

  String formatPrice(int price) {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return price
        .toString()
        .replaceAllMapped(formatter, (Match m) => '${m[1]}.');
  }

  bool isLongName(String name) {
    return name.length > 20 || name.contains('\n');
  }

  Future<void> _checkWishlistStatus() async {
    try {
      final wishlistItems = await wishlistService.fetchWishlist();
      setState(() {
        isInWishlist =
            wishlistItems.any((wl) => wl.product == widget.product.id);
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  void toggleWishlist() async {
    try {
      if (!isInWishlist) {
        //klo isInWishlist == false = belum ada di wishlist brrti ditambahin
        final success = await wishlistService.addToWishlist(widget.product.id);
        if (!success) throw Exception('Failed to add to wishlist');
        setState(() {
          isInWishlist = true;
        });
      } else {
        //klo isInWishlist == true = sudah ada di wishlist brrti dihapus
        final success =
            await wishlistService.removeFromWishlist(widget.product.id);
        if (!success) throw Exception('Failed to remove from wishlist');
        setState(() {
          isInWishlist = false;
        });
      }
    } catch (e) {
      // Kembalikan status jika gagal
      // setState(() {
      //   isInWishlist = !isInWishlist; // Rollback if the operation fails
      // });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update wishlist')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(isInWishlist ? 'Added to Wishlist' : 'Removed from Wishlist'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void initState() {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final sessionId = request.cookies['sessionid'];
    final csrfToken = request.cookies['csrftoken'];
    wishlistService = WishlistService(
        baseUrl: "http://10.0.2.2:8000",
        token: csrfToken!.value,
        sessionid: sessionId!.value);
    _checkWishlistStatus();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45;
    final cardHeight = cardWidth * 1.4;

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.all(4),
      child: Material(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final shouldRefresh = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  product: widget.product,
                  isAdmin: widget.isAdmin,
                  onEdit: widget.onEdit,
                ),
              ),
            );

            if (shouldRefresh == true) {
              widget.onEdit();
            }else{
              setState(() {
                _checkWishlistStatus();
              });
            }
          },
          child: Column(
            children: [
              // Image section with fixed aspect ratio
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: widget.product.image,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.error, size: 20),
                          ),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (widget.isAdmin)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.edit,
                                      size: 16, color: Colors.orange),
                                  onPressed: widget.onEdit,
                                ),
                              ),
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.delete,
                                      size: 16, color: Colors.red),
                                  onPressed: widget.onDelete,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.favorite, // Always use filled heart
                            color: isInWishlist
                                ? Colors.red
                                : Colors
                                    .grey, // Change color based on wishlist status
                            size: 24,
                          ),
                          onPressed: toggleWishlist,
                        ),
                      ),
                  ],
                ),
              ),
              // Content section
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12)),
                  ),
                  child: isLongName(widget.product.name)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.product.toko.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  widget.product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.brown[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Rp${formatPrice(widget.product.harga)}",
                                style: TextStyle(
                                  color: Colors.brown[800],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              widget.product.toko.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              widget.product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.brown[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Rp${formatPrice(widget.product.harga)}",
                                style: TextStyle(
                                  color: Colors.brown[800],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
