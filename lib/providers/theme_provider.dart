import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Toggle Tema
  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners(); // Memberitahu semua widget untuk update warna
  }

  // Palette Warna Dinamis
  Color get bgWhite => _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FB);
  Color get cardColor => _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : Colors.black;
  Color get subTextColor => _isDarkMode ? Colors.white70 : Colors.grey;
  
  // Warna Orange tetap dipertahankan sebagai identitas (Accent)
  static const Color orangeMain = Color(0xFFFE6F47);
}