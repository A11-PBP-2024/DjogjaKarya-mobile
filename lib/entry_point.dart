import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';

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
    BlogHomePage(),
    //DiscoverScreen(),
    //BookmarkScreen(),
    // EmptyCartScreen(), // if Cart is empty
    //CartScreen(),
    //ProfileScreen(),
  ];
  int _currentIndex = 0;

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
        // pinned: true,
        // floating: true,
        // snap: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        title: SvgPicture.asset(
          "assets/logo/Shoplon.svg",
          colorFilter: ColorFilter.mode(
              Theme.of(context).iconTheme.color!, BlendMode.srcIn),
          height: 20,
          width: 100,
        ),
         actions: [
          IconButton(
            onPressed: () {
              // Logika logout, misalnya:
              // context.read<AuthenticationProvider>().logout();
              Navigator.pushReplacementNamed(
                  context, '/login'); // Sesuaikan rute login
            },
            icon: SvgPicture.asset(
              "assets/icons/Logout.svg", // Ganti dengan ikon logout jika ada
              height: 24,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).textTheme.bodyLarge!.color!,
                  BlendMode.srcIn),
            ),
          ),
        ],
      ),
      // body: _pages[_currentIndex],
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