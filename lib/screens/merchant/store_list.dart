import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import '/models/store_entry.dart';
import '/screens/merchant/addstore_form.dart';
import '/screens/merchant/widgets/store_card.dart';  // Import the new file
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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
            backgroundColor: primaryColor,
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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Store Entry List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
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
                    itemBuilder: (_, index) => StoreCard(
                      store: _filteredStores[index],
                      onDeleteSuccess: () {
                        setState(() {
                          _isLoading = true;
                        });
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}