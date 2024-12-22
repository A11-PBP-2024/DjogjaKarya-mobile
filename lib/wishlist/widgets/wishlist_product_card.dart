import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/services/wishlist_service.dart';
import '/models/product.dart';
import '/screens/products/product_details_screen.dart';

class WishlistProductCard extends StatefulWidget {
  final int productId;
  final void Function()? onKlik;
  final void Function()? shouldRefresh;

  const WishlistProductCard({
    super.key,
    required this.productId,
    this.onKlik,
    this.shouldRefresh,
  });

  @override
  State<WishlistProductCard> createState() => _WishlistProductCardState();
}

class _WishlistProductCardState extends State<WishlistProductCard> {
  late WishlistService wishlistService;
  bool isInWishlist = false; // Status wishlist

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    final sessionId = request.cookies['sessionid'];
    final csrfToken = request.cookies['csrftoken'];
    wishlistService = WishlistService(
        baseUrl: "https://fauzan-putra31-djogjakarya1.pbp.cs.ui.ac.id",
        token: csrfToken!.value,
        sessionid: sessionId!.value);
    _checkWishlistStatus();

  }

  Future<void> _checkWishlistStatus() async {
    try {
      final wishlistItems = await wishlistService.fetchWishlist();
      setState(() {
        isInWishlist =
            wishlistItems.any((wl) => wl.product == widget.productId);
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  void toggleWishlist() async {
    try {
      if (!isInWishlist) {
        //klo isInWishlist == false = belum ada di wishlist brrti ditambahin
        final success = await wishlistService.addToWishlist(widget.productId);
        if (!success) throw Exception('Failed to add to wishlist');
        await _checkWishlistStatus();
      } else {
        //klo isInWishlist == true = sudah ada di wishlist brrti dihapus
        final success =
        await wishlistService.removeFromWishlist(widget.productId);
        if (!success) throw Exception('Failed to remove from wishlist');
        await _checkWishlistStatus();
      }
      widget.shouldRefresh!();
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

  String formatPrice(int price) {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return price
        .toString()
        .replaceAllMapped(formatter, (Match m) => '${m[1]}.');
  }

  bool isLongName(String name) {
    return name.length > 20 || name.contains('\n');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45;
    final cardHeight = cardWidth * 1.4;

    return FutureBuilder(
        future: wishlistService.getByProductId(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              width: cardWidth,
              height: cardHeight,
              margin: const EdgeInsets.all(4),
              child: Material(
                color: Colors.brown[50],
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onKlik,
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
                                  imageUrl: snapshot.data!.image,
                                  placeholder: (context, url) => const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.error, size: 20),
                                  ),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
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
                          child: isLongName(snapshot.data!.name)
                              ? Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      snapshot.data!.toko.toUpperCase(),
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
                                          snapshot.data!.name,
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
                                        "Rp${formatPrice(snapshot.data!.harga)}",
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      snapshot.data!.toko.toUpperCase(),
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
                                      snapshot.data!.name,
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
                                        "Rp${formatPrice(snapshot.data!.harga)}",
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
          } else {
            return Container(
              width: cardHeight,
              height: cardHeight,
              margin: const EdgeInsets.all(4),
              child: Text("Gagal"),
            );
          }
        });
  }
}
