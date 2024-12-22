import 'package:flutter/material.dart';
import 'package:shop/entry_point.dart';
// import '/screens/products/category_screen.dart';
import '/screens/products/category_products_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '/screens/home/views/carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CookieRequest request;

  @override
  void initState() {
    super.initState();
    request = context.read<CookieRequest>();
  }

  Widget _networkImageWithLoader({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey[400],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Introducing\nDjogjaKarya',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _networkImageWithLoader(
                      imageUrl: 'https://i.imgur.com/ZXQEDdn.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "From DjogjaKarya serves as a bridge connecting Yogyakarta's cultural heritage with the digital realm. Inspired by the word Djogja symbolizing uniqueness and strength, and Karya representing the creations of artisans, DjogjaKarya is a platform dedicated to marketing Yogyakarta's handcrafted products to a broader audience.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
            textAlign: TextAlign.justify, // Menambahkan justify alignment
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverSection(BuildContext context) {
    return Container(
      color: const Color(0xFF716969),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Text(
            'Discover the Charm of Djogjakarya',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Dive into the vibrant artistry and exquisite craftsmanship of beloved Yogyakarta. Discover the soul of Java through its unique art and cultural heritage like never before!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EntryPoint(initialIndex: 1), // 1 adalah indeks CategoriesScreen
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE38E27),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Explore Now!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, String imageUrl, BuildContext context) {
    return GestureDetector(
     onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsScreen(
              categoryName: name,
              isAdmin: false, // Role tidak relevan lagi
            ),
          ),
        );
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _networkImageWithLoader(
                imageUrl: imageUrl,
                height: 180,
                width: 300,
                fit: BoxFit.cover,
              ),
            ),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final categories = [
      {
        'name': 'Batik',
        'image':
            'https://img.freepik.com/premium-vector/elegant-vector-javanese-ethnic-batik-pattern-template_1325579-615.jpg'
      },
      {
        'name': 'Kerajinan Kulit',
        'image':
            'https://t3.ftcdn.net/jpg/02/26/92/86/360_F_226928653_CI7vW3087roWG6Ob9thI83Htd255aQyc.jpg'
      },
      {
        'name': 'Perak Kotagede',
        'image':
            'https://img.freepik.com/free-photo/silver-aesthetic-wallpaper-with-decorations_23-2149871747.jpg'
      },
      {
        'name': 'Kerajinan Wayang',
        'image':
            'https://img.freepik.com/free-vector/wayang-kulit-abstract-person-clouds_52683-46747.jpg'
      },
      {
        'name': 'Kerajinan Kayu',
        'image':
            'https://img.freepik.com/premium-photo/wooden-craft-floral-pattern-background-generative-aixa_174954-1884.jpg'
      },
      {
        'name': 'Kerajinan Anyaman',
        'image':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSNBX7I8TQW7SHCcSoIDXQispwmhe36wFHm4w&s'
      },
      {
        'name': 'Kerajinan Gerabah',
        'image':
            'https://cdn.shopify.com/s/files/1/0836/2769/files/hands-clay-pottery_600x600.jpg?v=1671439611'
      },
      {
        'name': 'Kerajinan Bambu',
        'image':
            'https://d12oja0ew7x0i8.cloudfront.net/images/news/ImageForNews_59774_16606539847736385.jpg'
      },
      {
        'name': 'Kain Tenun Lurik',
        'image':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDcwgUoIOogHLV9-USwv2jhHe_qgthcjvxAQ&s'
      },
      {
        'name': 'all',
        'image':
            'https://i.pinimg.com/originals/cb/13/9c/cb139cce577d1fde61b1e944f17a905a.jpg'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center( // Wrap dengan Center
            child: Column(
              children: [
                Text(
                  'Our Product Categories',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover a variety of new products and collections',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Scrollable Categories
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryItem(
                categories[index]['name']!,
                categories[index]['image']!,
                context,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceSection(BuildContext context) {
    final experienceItems = [
      {
        'image': 'https://jogjapasaraya.com/wp-content/uploads/2024/02/JOGJA-PASARAYA-770-x-960.webp',
      },
      {
        'image': 'https://jogjapasaraya.com/wp-content/uploads/2024/03/DSC_0173-scaled.webp',
      },
      {
        'image': 'https://jogjapasaraya.com/wp-content/uploads/2024/03/Oleh-Oleh-Yogyakarta-Jogja-Pasaraya.jpg',
      },
      {
        'image': 'https://i.pinimg.com/736x/49/d4/49/49d44964bb1c30ca04aaea2deb0b7fc1.jpg',
      },
      {
        'image': 'https://i.pinimg.com/736x/ee/cf/7f/eecf7f0c4a0cbf046919b5f4f81c3b14.jpg',
      },
      {
        'image': 'https://i.pinimg.com/736x/78/0f/1d/780f1d057d3b55b94051519e2bcde650.jpg',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience the Essence of Yogyakarta',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'We celebrate the rich craft and artistry of Yogyakarta, where tradition meets innovation. From skilled batik artisans to master sculptors, we draw inspiration from the vibrant creativity of our local culture.',
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          CarouselSlider(
            items: experienceItems,
            height: 250,
            autoPlayInterval: const Duration(seconds: 3),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildDiscoverSection(context),
            _buildCategoriesSection(context),
            _buildExperienceSection(context),
          ],
        ),
      ),
    );
  }
}