import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket_model.dart';
// Note: You might need to import your ApiConfig or constants file for baseUrl.
// For now, I'm assuming you have a constant URL. Update this path if needed.

class TicketService {
  // Ganti dengan baseUrl project Anda.
  final String baseUrl = 'https://generous-dragon-previously.ngrok-free.app/api'; 

  Future<List<Ticket>> fetchTickets(int studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tickets?student_id=$studentId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((json) => Ticket.fromJson(json))
              .toList();
        }
      }
      throw Exception('Failed to load tickets');
    } catch (e) {
      throw Exception('Error fetching tickets: $e');
    }
  }

  Future<Map<String, dynamic>> checkDuplicate(String subject, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets/check-duplicate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'subject': subject,
          'description': description,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to check duplicate');
    } catch (e) {
      throw Exception('Error checking duplicate: $e');
    }
  }

  Future<bool> createTicket(int studentId, String subject, String description, String priority) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_id': studentId,
          'subject': subject,
          'description': description,
          'priority': priority,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error creating ticket: $e');
    }
  }

  Future<Ticket> getTicketDetail(int ticketId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tickets/$ticketId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return Ticket.fromJson(data['data']);
        }
      }
      throw Exception('Failed to load ticket detail');
    } catch (e) {
      throw Exception('Error fetching ticket detail: $e');
    }
  }

  Future<bool> replyTicket(int ticketId, int studentId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets/$ticketId/reply'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_id': studentId,
          'message': message,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error sending reply: $e');
    }
  }

  Future<Map<String, dynamic>> rateTicket(int ticketId, int score, String feedback) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets/$ticketId/rate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'score': score,
          'feedback': feedback,
        }),
      );
      
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Error rating ticket: $e');
    }
  }
}
