import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import '/models/store_entry.dart';
import '/screens/merchant/addstore_form.dart';
import '/screens/merchant/widgets/store_card.dart';
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
  bool _isAdmin = false;
  late final CookieRequest request;

  @override
  void initState() {
    super.initState();
    request = context.read<CookieRequest>();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      // Fetch admin status separately
      final userResponse = await request.get('http://localhost:8000/merchant/get-user-status/');
      setState(() {
        _isAdmin = userResponse['is_admin'] ?? false;
      });
      
      // Fetch stores
      await fetchStore(request);
    } catch (e) {
      print('Error fetching initial data: $e');
    }
  }

  Future<void> fetchStore(CookieRequest request) async {
    try {
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
    } catch (e) {
      print('Error fetching stores: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
    if (!_isAdmin) return const SizedBox.shrink();

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
            ).then((_) => _fetchInitialData());
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Stores',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAddButton(),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildStoreList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreList() {
    if (_allStores.isEmpty) {
      return Center(
        child: Text(
          'Belum ada data store.',
          style: TextStyle(
            fontSize: 20,
            color: Colors.brown[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Column(
      children: [
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
              onDeleteSuccess: _fetchInitialData,
              isAdmin: _isAdmin,
            ),
          ),
        ),
      ],
    );
  }
}