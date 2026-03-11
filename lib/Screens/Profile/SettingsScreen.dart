import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/ThemeProvider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Appearance", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text("Light Mode"),
                  secondary: const Icon(Icons.wb_sunny_outlined),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (value) => themeProvider.setTheme(value!),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text("Dark Mode"),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (value) => themeProvider.setTheme(value!),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text("System Default"),
                  secondary: const Icon(Icons.settings_system_daydream),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (value) => themeProvider.setTheme(value!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}