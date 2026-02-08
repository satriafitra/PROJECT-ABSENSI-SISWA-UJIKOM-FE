import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/session.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  static const String baseUrl =
      'https://4257-202-46-68-134.ngrok-free.app/api'; // sama dengan ApiService

  static Future<List<AttendanceModel>> fetchHistory() async {
    final studentId = Session.id;

    final response = await http.get(
      Uri.parse('$baseUrl/attendance/$studentId'), // ✅ ganti di sini
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => AttendanceModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil riwayat absensi');
    }
  }
}
