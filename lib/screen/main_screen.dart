import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_providers.dart';
import '../providers/kuliner_provider.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'add_kuliner_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const AddKulinerScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load kuliner data when main screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KulinerProvider>(context, listen: false).loadKuliner();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.orange[600],
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_rounded,
                size: 24,
              ),
              activeIcon: Icon(
                Icons.home_rounded,
                size: 24,
                color: Colors.orange[600],
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search_rounded,
                size: 24,
              ),
              activeIcon: Icon(
                Icons.search_rounded,
                size: 24,
                color: Colors.orange[600],
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle_rounded,
                size: 24,
              ),
              activeIcon: Icon(
                Icons.add_circle_rounded,
                size: 24,
                color: Colors.orange[600],
              ),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_rounded,
                size: 24,
              ),
              activeIcon: Icon(
                Icons.person_rounded,
                size: 24,
                color: Colors.orange[600],
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
