// lib/screens/auth/auth_controller.dart

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final _isLoggedIn = false.obs;
  final _isLoading = false.obs;
  
  bool get isLoggedIn => _isLoggedIn.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;
    
    if (_isLoggedIn.value) {
      Get.offAllNamed('/home');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;
      
      // Simulasi delay network
      await Future.delayed(const Duration(seconds: 1));
      
      // Contoh validasi sederhana
      if (email == "test@mail.com" && password == "123456") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', email);
        
        _isLoggedIn.value = true;
        Get.offAllNamed('/home');
        
        Get.snackbar(
          'Success',
          'Welcome back!',
          snackPosition: SnackPosition.TOP,
        );
        
        return true;
      }
      
      Get.snackbar(
        'Error',
        'Invalid email or password',
        snackPosition: SnackPosition.TOP,
      );
      return false;
      
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading.value = true;
      
      // Simulasi delay network
      await Future.delayed(const Duration(seconds: 1));
      
      // Simpan data user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('name', name);
      await prefs.setString('email', email);
      
      _isLoggedIn.value = true;
      Get.offAllNamed('/home');
      
      Get.snackbar(
        'Success',
        'Registration successful!',
        snackPosition: SnackPosition.TOP,
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _isLoggedIn.value = false;
      Get.offAllNamed('/login');
      
      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}