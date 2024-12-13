// import 'package:flutter/material.dart';
// import 'package:shop/route/route_constants.dart';
// import 'package:shop/route/router.dart' as router;
// import 'package:shop/theme/app_theme.dart';

// void main() {
//   runApp(const MyApp());
// }


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Shop Template by The Flutter Way',
//       theme: AppTheme.lightTheme(context),
//       // Dark theme is inclided in the Full template
//       themeMode: ThemeMode.light,
//       onGenerateRoute: router.generateRoute,
//       initialRoute: onbordingScreenRoute,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Untuk jsonEncode dan jsonDecode

void main() async {
  // Pastikan binding diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Cek status login
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  var cookieRequest = CookieRequest();
  if (isLoggedIn) {
    await _restoreCookies(cookieRequest);
  }

  runApp(
    Provider<CookieRequest>.value(
      value: cookieRequest,
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

Future<void> _restoreCookies(CookieRequest cookieRequest) async {
  final prefs = await SharedPreferences.getInstance();
  final cookiesString = prefs.getString('cookies');
  if (cookiesString != null) {
    // Jika cookies diharapkan dalam format JSON
    final cookiesMap = jsonDecode(cookiesString);
    cookieRequest.cookies = cookiesMap;
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop Template by The Flutter Way',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      // Tentukan initial route berdasarkan status login
      initialRoute: isLoggedIn ? entryPointRoute : onbordingScreenRoute,
    );
  }
}

// Helper function untuk menyimpan status login
Future<void> saveLoginStatus(CookieRequest cookieRequest) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
  // Simpan cookies dalam format JSON
  final cookiesString = jsonEncode(cookieRequest.cookies);
  await prefs.setString('cookies', cookiesString);
}

// Helper function untuk logout
Future<void> clearLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);
  await prefs.remove('cookies');
}
