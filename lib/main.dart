import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_providers.dart';
import 'providers/kuliner_provider.dart';
import 'database/database_helper.dart';
import 'screen/splash_screen.dart';
import 'screen/login_screen.dart';
import 'screen/main_screen.dart';
import 'utils/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/favorite_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Starting BaliKuliner app...');

  try {
    // Initialize database
    print('Initializing database...');
    await DatabaseHelper.instance.database;
    print('Database initialized successfully');

    // Initialize SharedPreferences
    print('Initializing SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    print('SharedPreferences initialized successfully');

    print('Running app...');
    runApp(MyApp(prefs: prefs));
  } catch (e) {
    print('Error during initialization: $e');
    // Fallback: run app without database
    final prefs = await SharedPreferences.getInstance();
    runApp(MyApp(prefs: prefs));
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => KulinerProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider(prefs)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'BaliKuliner',
            theme: AppTheme.lightTheme,
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.materialThemeMode,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/login': (context) => const LoginScreen(),
              '/main': (context) => const MainScreen(),
            },
          );
        },
      ),
    );
  }
}
