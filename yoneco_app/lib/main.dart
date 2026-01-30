import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/issues_screen.dart';
import 'screens/counsellor_screen.dart';

void main() {
  runApp(const YonecoApp());
}

class YonecoApp extends StatelessWidget {
  const YonecoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tithandizane Helpline',
      theme: ThemeData(
        primaryColor: const Color(0xFF0A3D0A), // Dark Forest Green
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A3D0A), // Dark Forest Green for AppBar
          foregroundColor: Colors.white, // White text/icons on AppBar
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners for cards
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A3D0A), // Dark Forest Green for Elevated Buttons
            foregroundColor: Colors.white, // White text on buttons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners for buttons
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners for input fields
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF0A3D0A)), // Dark Forest Green border when focused
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400), // Light grey border when enabled
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF0A3D0A), // Dark Forest Green for FAB
          foregroundColor: Colors.white, // White icon on FAB
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/language': (context) => const LanguageSelectionScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/issues': (context) => const IssuesScreen(),
        '/counsellor': (context) => const CounsellorScreen(),
      },
    );
  }
}
