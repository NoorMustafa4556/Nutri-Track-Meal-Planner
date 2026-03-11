import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import '../Planning/MealPlannerScreen.dart';
import '../Planning/ShoppingListScreen.dart';
import '../Recipes/FavoritesScreen.dart';
import '../../Widgets/AppDrawer.dart'; // Import Drawer

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of screens
  final List<Widget> _screens = [
    const HomeScreen(),
    const MealPlannerScreen(),
    const ShoppingListScreen(),
    const FavoritesScreen(),
  ];

  // Titles for AppBar based on tab
  final List<String> _titles = [
    "Home",
    "Meal Planner",
    "Grocery List",
    "Favorites",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ AppBar yahan lagaya taake Drawer ka icon aaye
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(
          0xFF4CAF50,
        ), // Explicitly set color for visibility/branding
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ✅ Yahan Drawer lagaya
      drawer: const AppDrawer(),

      body: _screens[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          // Colors ab Theme se automatically aayenge (main.dart se)
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: "Planner",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Grocery",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favourites",
            ),
          ],
        ),
      ),
    );
  }
}
