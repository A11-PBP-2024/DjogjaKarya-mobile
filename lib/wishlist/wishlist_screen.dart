import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/screens/products/product_details_screen.dart';
import 'package:shop/screens/products/widgets/product_card.dart';
import 'package:shop/wishlist/widgets/wishlist_product_card.dart';

import '../../services/api_service.dart';
import '../../services/wishlist_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late WishlistService wishlistService;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: wishlistService.fetchWishlist(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final product = snapshot.data![index];
                  return WishlistProductCard(
                    productId: product.product,
                    shouldRefresh: (){
                      print("wow");
                      setState(() {
                        print("seharusnya refresh ");
                      });
                    },
                    onKlik: () async {
                      var prod = await wishlistService
                          .getByProductId(snapshot.data![index].product);
                      // final prefs = await SharedPreferences.getInstance();
                      if (context.mounted) {
                        final shouldRefresh = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              product: prod,
                              // isAdmin: prefs.getBool("isAdmin")??false,
                            ),
                          ),
                        );

                        if (shouldRefresh != null) {
                          setState(() {
                          });
                        }
                      }
                    },
                  );
                },
              );
            } else {
              return Text("Tidak ada data");
            }
          }),
);
}
}