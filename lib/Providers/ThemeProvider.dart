import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Default System Mode (Jo mobile ki setting hogi wahi chalega)
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners(); // Sab screens ko batao ke color change ho gaya
  }
}