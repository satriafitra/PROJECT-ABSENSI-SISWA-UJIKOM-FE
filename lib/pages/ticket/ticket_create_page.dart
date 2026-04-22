import 'package:flutter/material.dart';
import '../../services/ticket_service.dart';

class TicketCreatePage extends StatefulWidget {
  final int studentId;

  const TicketCreatePage({Key? key, required this.studentId}) : super(key: key);

  @override
  _TicketCreatePageState createState() => _TicketCreatePageState();
}

class _TicketCreatePageState extends State<TicketCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();
  String _priority = 'Low';
  bool _isLoading = false;
  final TicketService _ticketService = TicketService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Cek Duplikat
      final duplicateData = await _ticketService.checkDuplicate(
        _subjectController.text,
        _descController.text,
      );

      if (duplicateData['has_duplicate']) {
        setState(() => _isLoading = false);
        final bool proceed = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Perhatian!'),
            content: Text('Terdapat aduan serupa yang sedang diproses. Apakah Anda yakin ingin membuat tiket baru?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Batal', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Tetap Buat'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
        ) ?? false;

        if (!proceed) return;
        setState(() => _isLoading = true);
      }

      // Buat Tiket
      final success = await _ticketService.createTicket(
        widget.studentId,
        _subjectController.text,
        _descController.text,
        _priority,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tiket berhasil dibuat')));
        Navigator.pop(context, true); // Return true to refresh list
      } else {
        throw Exception('Failed to create ticket');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Buat Tiket Baru', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ceritakan kendala Anda dengan jelas agar tim support dapat menanganinya dengan cepat.',
                              style: TextStyle(fontSize: 12, color: Colors.orange[800], fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    Text('Detail Aduan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700], letterSpacing: 0.5)),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          labelText: 'Subjek',
                          hintText: 'Cth: Poin saya tidak masuk',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          prefixIcon: Icon(Icons.subject, color: Colors.grey[400]),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: TextFormField(
                        controller: _descController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          hintText: 'Jelaskan kendala Anda secara detail...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 70),
                            child: Icon(Icons.description_outlined, color: Colors.grey[400]),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                    ),
                    SizedBox(height: 32),
                    Text('Tingkat Prioritas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700], letterSpacing: 0.5)),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildPriorityOption('Low', Colors.grey),
                        SizedBox(width: 12),
                        _buildPriorityOption('Mid', Colors.orange),
                        SizedBox(width: 12),
                        _buildPriorityOption('High', Colors.red),
                      ],
                    ),
                    SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text('Kirim Aduan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: Colors.orange.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPriorityOption(String value, Color color) {
    bool isSelected = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.grey[300]!, width: isSelected ? 2 : 1),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              color: isSelected ? color : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
