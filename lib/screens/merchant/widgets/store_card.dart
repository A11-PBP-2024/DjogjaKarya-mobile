import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import '/models/store_entry.dart';
import '/screens/merchant/store_products.dart';
import '/screens/merchant/editstore_form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class StoreCard extends StatelessWidget {
  final StoreEntry store;
  final VoidCallback onDeleteSuccess;
  final bool isAdmin;

  const StoreCard({
    Key? key,
    required this.store,
    required this.onDeleteSuccess,
    required this.isAdmin,
  }) : super(key: key);

  Widget _buildAdminControls(BuildContext context) {
    if (!isAdmin) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditStoreFormPage(store: store),
                ),
              ).then((_) => onDeleteSuccess());
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showDetailDialog(BuildContext context) {
    final PageController pageController = PageController();
    final images = [
      store.fields.image1,
      store.fields.image2,
      store.fields.image3,
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.93,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'STORE DETAILS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          PageView.builder(
                            controller: pageController,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                images[index],
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SmoothPageIndicator(
                              controller: pageController,
                              count: images.length,
                              effect: ExpandingDotsEffect(
                                dotColor: Colors.white.withOpacity(0.5),
                                activeDotColor: Colors.white,
                                dotHeight: 8,
                                dotWidth: 8,
                                expansionFactor: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.fields.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            store.fields.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            store.fields.address,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    store.fields.opening_days,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, color: primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    store.fields.opening_hours,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final url = Uri.parse('tel:${store.fields.phone}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.phone, color: primaryColor, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      store.fields.phone,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StoreProductsPage(store: store, isAdmin: isAdmin),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.shopping_bag, color: primaryColor, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'View products in ${store.fields.name}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final url = Uri.parse(store.fields.location_link);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Directions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Admin controls now using the extracted method
                          _buildAdminControls(context),
                        ],
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

  void _showDeleteConfirmation(BuildContext context) {
    final request = context.read<CookieRequest>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${store.fields.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final response = await request.post(
                  'http://localhost:8000/merchant/delete-flutter/${store.pk}/',
                  {},
                );
                if (response['status'] == 'success') {
                  Navigator.pop(context);
                  onDeleteSuccess();
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetailDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                store.fields.image1,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.fields.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.fields.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        store.fields.opening_days,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        store.fields.opening_hours,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}