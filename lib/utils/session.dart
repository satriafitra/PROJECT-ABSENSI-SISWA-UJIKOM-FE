import 'package:shared_preferences/shared_preferences.dart';

class Session {
  // ================= CACHE (UNTUK UI) =================
  static int? id;
  static String? nisn;
  static String? studentName;
  static String? studentClass;
  static String? qrToken;

  // ================= SAVE LOGIN =================
  static Future<void> saveLogin(Map data) async {
    final prefs = await SharedPreferences.getInstance();

    // save ke local storage
    await prefs.setBool('isLogin', true);
    await prefs.setInt('id', data['id']);
    await prefs.setString('nisn', data['nisn']);
    await prefs.setString('name', data['name']);
    await prefs.setString('class', data['class']);
    await prefs.setString('qr_token', data['qr_token']);

    // save ke memory (INI YANG DIPAKAI UI)
    id = data['id'];
    nisn = data['nisn'];
    studentName = data['name'];
    studentClass = data['class'];
    qrToken = data['qr_token'];
  }

  // ================= LOAD SESSION =================
  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    id = prefs.getInt('id');
    nisn = prefs.getString('nisn');
    studentName = prefs.getString('name');
    studentClass = prefs.getString('class');
    qrToken = prefs.getString('qr_token');
  }

  // ================= CHECK LOGIN =================
  static Future<bool> isLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLogin') ?? false;
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    id = null;
    nisn = null;
    studentName = null;
    studentClass = null;
    qrToken = null;
  }
}
