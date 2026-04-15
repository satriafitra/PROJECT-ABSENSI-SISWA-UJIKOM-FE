import 'package:flutter/material.dart';
import '../utils/session.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // --- STATE UNTUK POIN ---
  int _studentPoints = 0;
  int get studentPoints => _studentPoints;

  // 🔥 AMBIL DARI SESSION (INI KUNCINYA)
  void loadPointsFromSession() {
    _studentPoints = Session.studentPoints ?? 0;
    notifyListeners();
  }

  // 🔥 UPDATE DARI API (ABSEN / REDEEM)
  void updatePoints(int newPoints) {
    _studentPoints = newPoints;
    notifyListeners();
  }

  // --- TEMA ---
  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  Color get bgWhite =>
      _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FB);
  Color get cardColor =>
      _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor =>
      _isDarkMode ? Colors.white : Colors.black;
  Color get subTextColor =>
      _isDarkMode ? Colors.white70 : Colors.grey;

  static const Color orangeMain = Color(0xFFFE6F47);
}