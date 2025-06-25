import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_providers.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('SplashScreen initialized');
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    print('Checking auth status...');
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        print('Current user: ${authProvider.currentUser}');

        if (authProvider.currentUser != null) {
          print('User logged in, navigating to main');
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          print('No user logged in, navigating to login');
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        print('Error in auth check: $e');
        // Fallback to login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building SplashScreen');
    return const Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'BaliKuliner',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Discover Authentic Balinese Cuisine',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
