import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://generous-dragon-previously.ngrok-free.app/api';

  // Helper untuk Headers agar tidak menulis berulang kali
  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ================= LOGIN SISWA =================
  static Future<Map<String, dynamic>> loginSiswa(
      String nisn, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login-siswa'),
        headers: _headers(),
        body: jsonEncode({'nisn': nisn, 'password': password}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // ================= AMBIL JADWAL HARI INI =================
  // Menyesuaikan dengan kebutuhan HomePage Anda
  static Future<Map<String, dynamic>> fetchJadwalGuru() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jadwal-guru'), // Sesuaikan endpoint Laravel Anda
        headers: _headers(),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Gagal mengambil jadwal: $e'};
    }
  }

  // ================= ABSENSI (SCAN QR) =================
  static Future<Map<String, dynamic>> submitAttendance({
    required int studentId,
    required String qrToken,
    required String createdAt, // 1. Tambahkan parameter wajib ini
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/absen'),
        headers: _headers(),
        body: jsonEncode({
          'student_id': studentId,
          'qr_token': qrToken,
          'created_at': createdAt, // <-- INI YANG KURANG (Masalah Utama)
        }),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Gagal melakukan absensi: $e'};
    }
  }

  // ================= RIWAYAT ABSENSI =================
  static Future<Map<String, dynamic>> fetchAttendanceHistory(
      int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/$studentId'),
        headers: _headers(),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Gagal memuat riwayat: $e'};
    }
  }

  // Helper function untuk memproses response & handling status code
  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        return {
          'status': false,
          'message': body['message'] ??
              'Terjadi kesalahan server (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Gagal memproses data dari server'};
    }
  }

  // ================= ABSENSI MANUAL (IZIN/SAKIT) =================
  static Future<Map<String, dynamic>> submitManualAttendance({
    required int studentId,
    required String status,
    required String keterangan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/absen-manual'),
        headers: _headers(),
        body: jsonEncode({
          'student_id': studentId,
          'status': status.toLowerCase(), // agar seragam 'sakit' atau 'izin'
          'keterangan': keterangan,
        }),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }
}
