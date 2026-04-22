class Ticket {
  final int id;
  final int reporterId;
  final String subject;
  final String description;
  final String priority;
  final String status;
  final DateTime createdAt;
  final List<TicketResponse> responses;
  final Map<String, dynamic>? rating;

  Ticket({
    required this.id,
    required this.reporterId,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.responses = const [],
    this.rating,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      reporterId: json['reporter_id'],
      subject: json['subject'],
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      responses: json['responses'] != null
          ? (json['responses'] as List)
              .map((r) => TicketResponse.fromJson(r))
              .toList()
          : [],
      rating: json['rating'],
    );
  }
}

class TicketResponse {
  final int id;
  final int ticketId;
  final String senderType; // 'student' or 'user'
  final String message;
  final DateTime createdAt;

  TicketResponse({
    required this.id,
    required this.ticketId,
    required this.senderType,
    required this.message,
    required this.createdAt,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      id: json['id'],
      ticketId: json['ticket_id'],
      senderType: json['sender_type'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
