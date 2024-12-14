import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For jsonEncode and jsonDecode

void main() async {
  // Ensure bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Check login status
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
    // Decode the JSON string to a Map<String, dynamic>
    final decodedMap = jsonDecode(cookiesString) as Map<String, dynamic>;

    // Convert Map<String, dynamic> to Map<String, Cookie>
    final cookiesMap = decodedMap.map((key, value) {
      return MapEntry(key, Cookie.fromJson(value));
    });

    // Assign the correctly typed Map to cookieRequest.cookies
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
      // Determine initial route based on login status
      initialRoute: isLoggedIn ? entryPointRoute : onbordingScreenRoute,
    );
  }
}

// Helper function to save login status
Future<void> saveLoginStatus(CookieRequest cookieRequest) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);

  // Convert Map<String, Cookie> to Map<String, dynamic> for JSON encoding
  final cookiesMap = cookieRequest.cookies.map((key, cookie) => MapEntry(key, cookie.toJson()));

  // Encode the cookies map to a JSON string
  final cookiesString = jsonEncode(cookiesMap);
  await prefs.setString('cookies', cookiesString);
}

// Helper function to logout
Future<void> clearLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);
  await prefs.remove('cookies');
}
