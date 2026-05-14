import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Managers/HHSessionManager.dart';
import 'package:hookahhabibi/Screen/Login/HHLogin.dart';
import 'package:hookahhabibi/Screen/Location/View/HHLocationScreen.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final HHSessionManager _sessionManager = HHSessionManager();
  final HHAppManager _appManager = HHAppManager();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash for minimum 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is already logged in
    final isLoggedIn = await _checkLoginStatus();

    if (!mounted) return;

    if (isLoggedIn) {
      // User is logged in, navigate to location screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HHLocationScreen()),
      );
    } else {
      // User not logged in, navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HHLogin()),
      );
    }
  }

  Future<bool> _checkLoginStatus() async {
    try {
      // Check if session manager has valid session
      if (!_sessionManager.isSessionValid()) {
        return false;
      }

      // Validate token with backend
      final isValid = await _appManager.initialize();

      if (isValid) {
        // Load initial data
        await _appManager.locationManager.loadLocations();
        await _appManager.menuManager.loadCategories();
        return true;
      }

      return false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(APPImages.icSplashBg),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
          ),
        ),
      ),
    );
  }
}