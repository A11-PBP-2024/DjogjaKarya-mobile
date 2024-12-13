import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/models/product.dart';

class ProductCard extends StatelessWidget {
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

  String formatPrice(int price) {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return price.toString().replaceAllMapped(
      formatter, 
      (Match m) => '${m[1]}.'
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan lebar layar
    final screenWidth = MediaQuery.of(context).size.width;
    // Mengatur lebar kartu sebagai persentase dari lebar layar
    final cardWidth = screenWidth * 0.45; // 45% dari lebar layar
    // Mengatur tinggi kartu berdasarkan lebar
    final cardHeight = cardWidth * 1.6; // Rasio 1:1.6

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: OutlinedButton(
        onPressed: () {
          // Tambahkan onPressed event jika diperlukan
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(8),
          backgroundColor: Colors.brown[100], // Warna latar belakang coklat muda
          side: BorderSide(color: Colors.grey.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          children: [
            // Bagian gambar dengan rasio aspek tetap
            AspectRatio(
              aspectRatio: 1.15,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isAdmin)
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
                            IconButton(
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 30,
                                minHeight: 30,
                              ),
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: onEdit,
                            ),
                            IconButton(
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 30,
                                minHeight: 30,
                              ),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: onDelete,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Bagian informasi produk
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Nama toko
                    Text(
                      product.toko.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    // Nama produk
                    Flexible(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    
                    // Harga
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.brown[200], // Warna latar belakang label harga
                      ),
                      child: Text(
                        "Rp${formatPrice(product.harga)}",
                        style: TextStyle(
                          color: Colors.brown[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
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
    );
  }
}
