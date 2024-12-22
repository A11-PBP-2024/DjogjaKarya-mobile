import 'package:flutter/material.dart';
import '/models/category_item.dart';
import '/screens/products/category_products_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<CategoryItem> categories = [];
  List<CategoryItem> filteredCategories = [];
  bool isLoading = true;
  bool isAdmin = false;
  String username = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchCategories();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = prefs.getBool('isAdmin') ?? false;
      username = prefs.getString('username') ?? '';
    });
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCategories = List.from(categories);
      } else {
        filteredCategories = categories
            .where((category) =>
                category.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _fetchCategories() async {
    List<CategoryItem> dummyData = [
      CategoryItem(
        name: "Batik",
        imageUrl:
            "https://img.freepik.com/premium-vector/elegant-vector-javanese-ethnic-batik-pattern-template_1325579-615.jpg",
      ),
      CategoryItem(
        name: "Kerajinan Kulit",
        imageUrl:
            "https://t3.ftcdn.net/jpg/02/26/92/86/360_F_226928653_CI7vW3087roWG6Ob9thI83Htd255aQyc.jpg",
      ),
      CategoryItem(
        name: "Perak Kotagede",
        imageUrl:
            "https://img.freepik.com/free-photo/silver-aesthetic-wallpaper-with-decorations_23-2149871747.jpg",
      ),
      CategoryItem(
        name: "Kerajinan Wayang",
        imageUrl:
            "https://img.freepik.com/free-vector/wayang-kulit-abstract-person-clouds_52683-46747.jpg",
      ),
      CategoryItem(
        name: "Kerajinan Kayu",
        imageUrl:
            "https://img.freepik.com/premium-photo/wooden-craft-floral-pattern-background-generative-aixa_174954-1884.jpg",
      ),
      CategoryItem(
        name: "Kerajinan Anyaman",
        imageUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSNBX7I8TQW7SHCcSoIDXQispwmhe36wFHm4w&s",
      ),
      CategoryItem(
        name: "Kerajinan Gerabah",
        imageUrl:
            "https://cdn.shopify.com/s/files/1/0836/2769/files/hands-clay-pottery_600x600.jpg?v=1671439611",
      ),
      CategoryItem(
        name: "Kerajinan Bambu",
        imageUrl:
            "https://d12oja0ew7x0i8.cloudfront.net/images/news/ImageForNews_59774_16606539847736385.jpg",
      ),
      CategoryItem(
        name: "Kain Tenun Lurik",
        imageUrl:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDcwgUoIOogHLV9-USwv2jhHe_qgthcjvxAQ&s",
      ),
      CategoryItem(
        name: "all",
        imageUrl:
            "https://i.pinimg.com/originals/cb/13/9c/cb139cce577d1fde61b1e944f17a905a.jpg",
      ),
    ];

    setState(() {
      categories = dummyData;
      filteredCategories = dummyData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Products")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                "Loading products...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isAdmin
                    ? "Hi, $username!\nAny updates?"
                    : "Hello,$username!\nWhat would you like to explore?",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: _filterCategories,
              ),
            ),

            // Categories Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Categories",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Categories Grid
            Expanded(
              child: filteredCategories.isEmpty
                  ? Center(
                      child: Text(
                        "No categories found",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryProductsScreen(
                                  categoryName: category.name,
                                  isAdmin: isAdmin,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(category.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(color: Colors.black.withOpacity(0.3)),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      category.name,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}