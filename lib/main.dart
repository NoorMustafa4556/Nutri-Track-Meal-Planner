import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Providers/ThemeProvider.dart';
import 'Providers/RecipeProvider.dart'; // Import RecipeProvider
import 'Services/AuthService.dart'; // Import AuthService
import 'Screens/Recipes/FavoritesScreen.dart';
import 'Screens/Planning/MealPlannerScreen.dart';
import 'Screens/Planning/ShoppingListScreen.dart';
import 'Screens/Auth/SplashScreen.dart';
import 'Screens/Auth/LoginScreen.dart';
import 'Screens/Auth/SignUpScreen.dart';

import 'Screens/Profile/ProfileScreen.dart';
import 'Screens/Home/MainScreen.dart';
import 'Screens/Profile/SettingsScreen.dart'; // Nayi File Import ki

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meal Planner',

      // 🟢 Light Theme (Saaf aur Bright)
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF4CAF50),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        cardColor: Colors.white, // Cards White rahenge
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Text Field ki styling yahan set ki
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      // ⚫ Dark Theme (Professional Dark Grey - Aankhon ke liye behtar)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4CAF50),
        scaffoldBackgroundColor: const Color(0xFF121212), // Gehra Kala
        cardColor: const Color(0xFF1E1E1E), // Cards thore lighter dark honge
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Dark Mode Text Field
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C), // Input box dark grey hoga
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Color(0xFF81C784),
          unselectedItemColor: Colors.grey,
        ),
      ),

      themeMode: themeProvider.themeMode,

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/planner': (context) => const MealPlannerScreen(),
        '/grocery': (context) => const ShoppingListScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
