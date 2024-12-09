import 'package:flutter/material.dart';
import 'package:djogjakarya/merchant/models/store_entry.dart';
import 'package:djogjakarya/merchant/screens/product_store.dart';
import 'package:djogjakarya/merchant/screens/addstore_form.dart';
import 'package:djogjakarya/merchant/screens/editstore_form.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class StoreEntryPage extends StatefulWidget {
  const StoreEntryPage({super.key});

  @override
  State<StoreEntryPage> createState() => _StoreEntryPageState();
}

class _StoreEntryPageState extends State<StoreEntryPage> {
  String _searchQuery = '';
  List<StoreEntry> _allStores = [];
  List<StoreEntry> _filteredStores = [];
  bool _isLoading = true;
  late final CookieRequest request;

  @override
  void initState() {
    super.initState();
    request = context.read<CookieRequest>();
  }

  Future<void> fetchStore(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/merchant/get-stores/');
    setState(() {
      _allStores = [];
      for (var d in response) {
        if (d != null) {
          _allStores.add(StoreEntry.fromJson(d));
        }
      }
      _filteredStores = List.from(_allStores);
      _isLoading = false;
    });
  }

  void _filterStores(String query) {
    setState(() {
      _searchQuery = query;
      _filteredStores = _allStores
          .where((store) =>
              store.fields.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Store Entry List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
      backgroundColor: Colors.brown[50],
      body: FutureBuilder(
        future: _isLoading ? fetchStore(request) : null,
        builder: (context, AsyncSnapshot snapshot) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (_allStores.isEmpty) {
            return Column(
              children: [
                _buildAddButton(),
                Center(
                  child: Text(
                    'Belum ada data store.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.brown[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                _buildAddButton(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: _filterStores,
                      decoration: InputDecoration(
                        hintText: 'Search stores...',
                        prefixIcon: Icon(Icons.search, color: Colors.brown[700]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Found ${_filteredStores.length} store(s)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredStores.length,
                    itemBuilder: (_, index) => _buildStoreCard(_filteredStores[index]),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StoreEntryFormPage(),
              ),
            ).then((_) {
              setState(() {
                _isLoading = true;
              });
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Store'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreCard(StoreEntry store) {
    final PageController pageController = PageController();
    final images = [
      store.fields.image1,
      store.fields.image2,
      store.fields.image3,
    ];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(15),
                    ),
                    child: SizedBox(
                      height: 400,
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: images.length,
                        itemBuilder: (context, imageIndex) {
                          return Image.network(
                            images[imageIndex],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildErrorContainer(),
                            loadingBuilder: (context, child, loadingProgress) =>
                                loadingProgress == null
                                    ? child
                                    : _buildLoadingContainer(),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
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
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.fields.name,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      store.fields.description,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.location_on, store.fields.address),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.calendar_today, store.fields.opening_days),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.access_time, store.fields.opening_hours),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.phone, store.fields.phone),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(store.fields.location_link);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        icon: const Icon(Icons.location_on),
                        label: const Text('Lihat Lokasi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditStoreFormPage(store: store),
                                ),
                              ).then((_) {
                                setState(() {
                                  _isLoading = true;
                                });
                              });
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Deletion'),
                                    content: Text('Are you sure you want to delete ${store.fields.name}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
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
                                            setState(() {
                                              _isLoading = true;
                                            });
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
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.brown[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Text(
          'Error loading image',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}