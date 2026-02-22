import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://dbf8-202-46-68-130.ngrok-free.app/api';

  // ================= LOGIN SISWA =================
  static Future<Map<String, dynamic>> loginSiswa(
      String nisn, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login-siswa'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'nisn': nisn,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  // ================= ABSENSI (SCAN QR) =================
  static Future<Map<String, dynamic>> submitAttendance({
    required int studentId,
    required String qrToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/absen'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'student_id': studentId,
        'qr_token': qrToken,
      }),
    );

    return jsonDecode(response.body);
  }

  // ================= RIWAYAT ABSENSI =================
  static Future<Map<String, dynamic>> fetchAttendanceHistory(
      int studentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/attendance/$studentId'),
      headers: {
        'Accept': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }
}
