import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static int? id;
  static String? nisn;
  static String? studentName;
  static String? studentClass;
  static String? qrToken;
  static int? studentPoints; // Sudah ada

  static List<Map<String, dynamic>> attendanceHistory = [];

  // ================= SAVE LOGIN =================
  static Future<void> saveLogin(Map data) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLogin', true);
    await prefs.setInt('id', data['id']);
    await prefs.setString('nisn', data['nisn']);
    await prefs.setString('name', data['name']);
    await prefs.setString('class', data['class']);
    await prefs.setString('qr_token', data['qr_token']);
    // TAMBAHKAN INI: Simpan poin ke SharedPreferences
    await prefs.setInt('points', data['points'] ?? 0); 

    id = data['id'];
    nisn = data['nisn'];
    studentName = data['name'];
    studentClass = data['class'];
    qrToken = data['qr_token'];
    // TAMBAHKAN INI: Isi variabel static
    studentPoints = data['points'] ?? 0; 
  }

  // ================= LOAD SESSION =================
  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    id = prefs.getInt('id');
    nisn = prefs.getString('nisn');
    studentName = prefs.getString('name');
    studentClass = prefs.getString('class');
    qrToken = prefs.getString('qr_token');
    // TAMBAHKAN INI: Ambil poin dari memori saat aplikasi dibuka
    studentPoints = prefs.getInt('points') ?? 0; 
  }

  // ================= UPDATE POINTS (TAMBAHAN PENTING) =================
  // Panggil fungsi ini saat absen berhasil agar poin di memori HP bertambah
  static Future<void> updatePoints(int newPoints) async {
    final prefs = await SharedPreferences.getInstance();
    studentPoints = newPoints;
    await prefs.setInt('points', newPoints);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    id = null;
    nisn = null;
    studentName = null;
    studentClass = null;
    qrToken = null;
    studentPoints = null; // Reset poin saat logout
    attendanceHistory.clear();
  }
}