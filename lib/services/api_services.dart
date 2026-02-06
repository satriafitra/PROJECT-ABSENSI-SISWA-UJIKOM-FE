import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://bec4-202-46-68-134.ngrok-free.app/api';
  // ⚠ ganti IP kalau pakai HP

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
}
