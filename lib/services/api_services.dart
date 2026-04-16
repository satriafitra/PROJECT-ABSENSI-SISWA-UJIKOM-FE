import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/session.dart';
// Ganti 'your_project_name' dengan nama project kamu yang ada di pubspec.yaml
import 'package:absensi_app/models/assessment_model.dart';

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
  static Future<Map<String, dynamic>> fetchJadwalGuru() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jadwal-guru'),
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
    required String createdAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/absen'),
        headers: _headers(),
        body: jsonEncode({
          'student_id': studentId,
          'qr_token': qrToken,
          'created_at': createdAt,
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

  // ================= ABSENSI MANUAL (IZIN/SAKIT) DENGAN FOTO =================
  static Future<Map<String, dynamic>> submitManualAttendance({
    required int studentId,
    required String status,
    required String keterangan,
    File? imageFile,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/absen-manual');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
      });

      request.fields['student_id'] = studentId.toString();
      request.fields['status'] = status.toLowerCase();
      request.fields['keterangan'] = keterangan;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // ================= AMBIL PENILAIAN TERBARU =================
  static Future<AssessmentModel?> fetchLatestAssessment(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/assessment/$studentId'),
        headers: _headers(),
      );

      final result = _processResponse(response);

      // Pastikan status sukses dan 'data' tidak null
      if ((result['status'] == 'success' || result['status'] == true) &&
          result['data'] != null) {
        return AssessmentModel.fromJson(result['data']);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetchAssessment: $e');
      return null;
    }
  }

  // ================= MARKETPLACE =================
  static Future<List<dynamic>> fetchMarketplace() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/marketplace'),
        headers: _headers(),
      );

      final result = _processResponse(response);

      if (result['success'] == true && result['data'] != null) {
        return result['data'];
      } else {
        return [];
      }
    } catch (e) {
      print('Error marketplace: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> redeemItem({
    required int studentId,
    required int itemId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/marketplace/redeem'),
        headers: _headers(),
        body: jsonEncode({
          'student_id': studentId,
          'item_id': itemId,
        }),
      );

      return _processResponse(response);
    } catch (e) {
      return {'status': false, 'message': 'Gagal membeli voucher: $e'};
    }
  }

  static Future<List<dynamic>> fetchMyVouchers(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-vouchers/$studentId'),
        headers: _headers(),
      );

      final result = _processResponse(response);

      if (result['success'] == true && result['data'] != null) {
        return result['data'];
      } else {
        return [];
      }
    } catch (e) {
      print('Error inventory: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> useVoucher({
    required int voucherId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/use-voucher"),
        headers: _headers(), // 🔥 PENTING (JSON HEADER)
        body: jsonEncode({
          "voucher_id": voucherId,
          "student_id": Session.id,
        }),
      );

      return _processResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal koneksi server: $e',
      };
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
}
