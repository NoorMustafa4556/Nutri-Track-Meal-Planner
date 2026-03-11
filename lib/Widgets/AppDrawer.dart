import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/ThemeProvider.dart';
import '../Services/AuthService.dart';
import '../Services/DatabaseService.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeProvider access karein taake mode change kar sakein
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          // Header
          Consumer<AuthService>(
            builder: (context, auth, _) {
              final user = auth.currentUser;
              return FutureBuilder<Map<String, dynamic>?>(
                // Fetch extra data like Name if not in Auth Object (e.g. from Firestore)
                // For now, we use Auth DisplayName or Email
                future:
                    user != null
                        ? DatabaseService().getUserProfile(user.uid)
                        : null,
                builder: (context, snapshot) {
                  String name = "Guest";
                  String email = "No Email";
                  if (user != null) {
                    email = user.email ?? "No Email";
                    // Try to get name from Auth or Firestore
                    if (snapshot.hasData && snapshot.data != null) {
                      // Assuming we saved name in Firestore? We actually didn't explicitly save 'name' in saveUserProfile yet
                      // Check SignUpScreen logic... it only creates Auth User.
                      // Let's use user.email for now or Guest
                      name = user.email!.split('@')[0]; // Temporary fallback
                    }
                  }

                  return UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? const Color(0xFF1F1F1F)
                              : const Color(0xFF4CAF50),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "U",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                    accountName: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    accountEmail: Text(email),
                  );
                },
              );
            },
          ),

          // 1. My Profile
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("My Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),

          // 2. Home
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),

          // 3. Meal Planner
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text("Meal Planner"),
            onTap: () {
              Navigator.pop(context);
              // Ensure karein ke main.dart mein '/planner' route define ho
              Navigator.pushNamed(context, '/planner');
            },
          ),

          // 4. Grocery List
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text("Grocery List"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/grocery');
            },
          ),

          // 5. Favorites
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text("Favorites"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/favorites');
            },
          ),

          const Divider(),

          // 6. Light/Dark Mode Toggle (Settings ki jagah)
          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            value: isDark,
            activeColor: const Color(0xFF4CAF50), // Green switch color
            onChanged: (value) {
              // Toggle logic
              final newTheme = value ? ThemeMode.dark : ThemeMode.light;
              themeProvider.setTheme(newTheme);
            },
          ),

          const Spacer(), // Logout ko neeche dhakel dega

          const Divider(),

          // 7. Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
