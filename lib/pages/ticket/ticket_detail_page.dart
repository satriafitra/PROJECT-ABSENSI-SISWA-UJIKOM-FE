import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';
import '../../services/ticket_service.dart';

class TicketDetailPage extends StatefulWidget {
  final int ticketId;
  final int studentId;

  const TicketDetailPage({Key? key, required this.ticketId, required this.studentId}) : super(key: key);

  @override
  _TicketDetailPageState createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final TicketService _ticketService = TicketService();
  Ticket? _ticket;
  bool _isLoading = true;
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    try {
      final ticket = await _ticketService.getTicketDetail(widget.ticketId);
      setState(() => _ticket = ticket);
      
      // Jika status closed dan belum dirate, tampilkan popup rating
      if (ticket.status == 'Closed' && ticket.rating == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showRatingDialog();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat detail tiket')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendReply() async {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() => _isSending = true);
    try {
      final success = await _ticketService.replyTicket(widget.ticketId, widget.studentId, _messageController.text);
      if (success) {
        _messageController.clear();
        _fetchDetail(); // reload chat
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim pesan')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _showRatingDialog() async {
    int rating = 5;
    final feedbackController = TextEditingController();
    bool isSubmitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.star_rounded, size: 48, color: Colors.orange),
                    ),
                    SizedBox(height: 16),
                    Text('Tiket Telah Selesai', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
                    SizedBox(height: 8),
                    Text(
                      'Seberapa puas Anda dengan layanan kami? Penilaian Anda akan memberi Anda +5 Poin tambahan!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setStateDialog(() => rating = index + 1),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: index < rating ? Colors.amber[500] : Colors.grey[300],
                              size: index < rating ? 48 : 40,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: feedbackController,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan pengalaman Anda (Opsional)...',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.orange)),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 24),
                    isSubmitting 
                      ? CircularProgressIndicator(color: Colors.orange)
                      : SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor: Colors.orange.withOpacity(0.4),
                            ),
                            onPressed: () async {
                              setStateDialog(() => isSubmitting = true);
                              try {
                                final res = await _ticketService.rateTicket(widget.ticketId, rating, feedbackController.text);
                                Navigator.pop(context); // Tutup dialog
                                
                                if (res['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.stars_rounded, color: Colors.white, size: 28),
                                          SizedBox(width: 12),
                                          Expanded(child: Text(res['message'], style: TextStyle(fontWeight: FontWeight.bold))),
                                        ],
                                      ),
                                      backgroundColor: Colors.orange[600],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      margin: EdgeInsets.all(16),
                                      duration: Duration(seconds: 4),
                                    )
                                  );
                                  _fetchDetail(); // Reload agar rating button hilang
                                }
                              } catch (e) {
                                setStateDialog(() => isSubmitting = false);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim penilaian')));
                              }
                            },
                            child: Text('Kirim Penilaian', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        )
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _ticket == null) {
      return Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Support', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('ID: #TK-${_ticket!.id.toString().padLeft(4, '0')}', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          if (_ticket!.status == 'Closed' && _ticket!.rating == null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.star_rate_rounded, color: Colors.orange, size: 24),
                onPressed: _showRatingDialog,
                tooltip: 'Berikan Penilaian',
              ),
            )
        ],
      ),
      body: Column(
        children: [
          // Premium Header Info
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: Offset(0, 5))
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(_ticket!.status),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                        SizedBox(width: 4),
                        Text(
                          "${_ticket!.createdAt.day}/${_ticket!.createdAt.month}/${_ticket!.createdAt.year}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 16),
                Text(_ticket!.subject, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black87)),
              ],
            ),
          ),
          
          // Scrollable Content (Timeline + Chat)
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Info Boxes
                Row(
                  children: [
                    Expanded(child: _buildInfoBox('KATEGORI', 'Layanan Sekolah', Icons.category)),
                    SizedBox(width: 12),
                    Expanded(child: _buildInfoBox('PRIORITAS', _ticket!.priority + ' Priority', Icons.flag)),
                  ],
                ),
                SizedBox(height: 24),
                
                // Resolution Timeline
                Text('RESOLUTION TIMELINE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey[700])),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimelineItem('Ticket Submitted', '${_ticket!.createdAt.day}/${_ticket!.createdAt.month}/${_ticket!.createdAt.year} • ${_ticket!.createdAt.hour}:${_ticket!.createdAt.minute}', true, false),
                      _buildTimelineItem('In Progress', 'Agen sedang mereview keluhan', _ticket!.status == 'In-Progress' || _ticket!.status == 'Closed', false),
                      _buildTimelineItem('Resolved', 'Penyelesaian sesuai', _ticket!.status == 'Closed', true),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SUPPORT THREAD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey[700])),
                    Text('INTERNAL SYNC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                  ],
                ),
                SizedBox(height: 16),
                
                // Pesan awal (dari tiket)
                _buildMessageBubble(
                  message: _ticket!.description,
                  isMe: true,
                  time: _ticket!.createdAt,
                  senderName: 'Anda',
                ),
                
                // Balasan
                ..._ticket!.responses.map((r) {
                  bool isMe = r.senderType == 'student';
                  return _buildMessageBubble(
                    message: r.message,
                    isMe: isMe,
                    time: r.createdAt,
                    senderName: isMe ? 'Anda' : 'Admin Support',
                  );
                }).toList(),
              ],
            ),
          ),

          // Input Area
          if (_ticket!.status != 'Closed')
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan balasan...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    radius: 24,
                    child: _isSending 
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : IconButton(
                          icon: Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _sendReply,
                        ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[100],
              alignment: Alignment.center,
              child: Text('Percakapan telah ditutup', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            )
        ],
      ),
    );
  }

  Widget _buildMessageBubble({required String message, required bool isMe, required DateTime time, required String senderName}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              "$senderName • ${time.hour}:${time.minute.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? Colors.orange : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isMe ? 0.1 : 0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                )
              ],
              border: isMe ? null : Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    if (status == 'Open') {
      bgColor = Colors.blue[50]!;
      textColor = Colors.blue;
    } else if (status == 'In-Progress') {
      bgColor = Colors.orange[50]!;
      textColor = Colors.orange;
    } else {
      bgColor = Colors.grey[100]!;
      textColor = Colors.grey[600]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[500]),
              SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5)),
            ],
          ),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, bool isCompleted, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.orange : Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(color: isCompleted ? Colors.orange : Colors.grey[300]!, width: 2),
              ),
              child: isCompleted ? Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? Colors.orange : Colors.grey[200],
              ),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isCompleted ? Colors.black87 : Colors.grey[400])),
              SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              if (!isLast) SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
