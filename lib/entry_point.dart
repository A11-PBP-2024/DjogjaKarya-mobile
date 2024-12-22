import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  final List _pages = const [
    HomeScreen(),
    CategoriesScreen(),
    HomeScreen(),
    StoreEntryPage(),
    HomeScreen(),
  ];
  int _currentIndex = 0;
  String _username = ""; // Variabel untuk menyimpan nama pengguna

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Fungsi untuk memuat nama pengguna dari SharedPreferences
  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? "Guest"; // Default "Guest" jika tidak ditemukan
    });
  }

  @override
  Widget build(BuildContext context) {
    SvgPicture svgIcon(String src, {Color? color}) {
      return SvgPicture.asset(
        src,
        height: 24,
        colorFilter: ColorFilter.mode(
            color ??
                Theme.of(context).iconTheme.color!.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 0.3 : 1),
            BlendMode.srcIn),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE38E27), // Warna oranye
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            child: Image.network(
              "https://i.imgur.com/Iu7BTnD.png", // Path logo
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Row(
          children: [
            const SizedBox(width: 5), // Jarak kecil antara logo dan tulisan
            Text(
              "DjogjaKarya",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(
                "Hello, $_username 👋🏻", // Ganti dengan nama pengguna dinamis
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png", // URL gambar profil pengguna
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: defaultPadding / 2),
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF101015),
          type: BottomNavigationBarType.fixed,
          // selectedLabelStyle: TextStyle(color: primaryColor),
          selectedFontSize: 12,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, color: primaryColor),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category, color: primaryColor),
              label: "Products",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark, color: primaryColor),
              label: "Wishlist",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront, color: primaryColor),
              label: "Merchant",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article, color: primaryColor),
              label: "Articles",
            ),
          ],
        ),
      ),
    );
  }
}