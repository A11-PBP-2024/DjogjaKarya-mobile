// categories_screen.dart
import 'package:flutter/material.dart';
import '/models/category_item.dart';
import '/screens/products/category_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<CategoryItem> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    // Hardcode atau fetch dari API
  List<CategoryItem> dummyData = [
  CategoryItem(
    name: "Batik",
    imageUrl: "https://img.freepik.com/premium-vector/elegant-vector-javanese-ethnic-batik-pattern-template_1325579-615.jpg",
  ),
  CategoryItem(
    name: "Kerajinan Kulit",
    imageUrl: "https://t3.ftcdn.net/jpg/02/26/92/86/360_F_226928653_CI7vW3087roWG6Ob9thI83Htd255aQyc.jpg",
  ),
  CategoryItem(
    name: "Perak Kotagede",
    imageUrl: "https://img.freepik.com/free-photo/silver-aesthetic-wallpaper-with-decorations_23-2149871747.jpg",
  ),
  CategoryItem(
    name: "Kerajinan Wayang",
    imageUrl: "https://img.freepik.com/free-vector/wayang-kulit-abstract-person-clouds_52683-46747.jpg",
  ),
  CategoryItem(
    name: "Kerajinan Kayu",
    imageUrl: "https://img.freepik.com/premium-photo/wooden-craft-floral-pattern-background-generative-aixa_174954-1884.jpg",
  ),
  CategoryItem(
    name: "Kerajinan Anyaman",
    imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSNBX7I8TQW7SHCcSoIDXQispwmhe36wFHm4w&s",
  ),
  CategoryItem(
    name: "Kerajinan Gerabah",
    imageUrl: "https://cdn.shopify.com/s/files/1/0836/2769/files/hands-clay-pottery_600x600.jpg?v=1671439611",
  ),
  CategoryItem(
    name: "Kerajinan Bambu",
    imageUrl: "https://d12oja0ew7x0i8.cloudfront.net/images/news/ImageForNews_59774_16606539847736385.jpg",
  ),
  CategoryItem(
    name: "Kain Tenun Lurik",
    imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDcwgUoIOogHLV9-USwv2jhHe_qgthcjvxAQ&s",
  ),
  CategoryItem(
    name: "all",
    imageUrl: "https://i.pinimg.com/originals/cb/13/9c/cb139cce577d1fde61b1e944f17a905a.jpg",
  ),
];

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      categories = dummyData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Categories")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Form
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Find something...",
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.search,
                      color: Theme.of(context).iconTheme.color!.withOpacity(0.3),
                    ),
                  ),
                  suffixIcon: SizedBox(
                    width: 40,
                    child: Row(
                      children: [
                        const SizedBox(
                          height: 24,
                          child: VerticalDivider(width: 1),
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () {}, // Tambahkan fungsi filter disini
                            icon: Icon(
                              Icons.filter_list,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
            
            // Categories Grid (ini tetap menggunakan grid yang sudah ada)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryProductsScreen(
                            categoryName: category.name,
                            isAdmin: true,
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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