import 'package:flutter/material.dart';
import '../../models/ticket_model.dart';
import '../../services/ticket_service.dart';
import 'ticket_create_page.dart';
import 'ticket_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketListPage extends StatefulWidget {
  @override
  _TicketListPageState createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  final TicketService _ticketService = TicketService();
  List<Ticket> _tickets = [];
  bool _isLoading = true;
  int _studentId = 0;

  // Palet Warna Orange Modern
  static const Color primaryOrange = Color(0xFFFF6B00); // Orange Cerah
  static const Color accentOrange = Color(0xFFFF9E00); // Orange Kekuningan
  static const Color darkOrange = Color(0xFFCC5500); // Orange Gelap
  static const Color bgGrey = Color(0xFFF8FAFC); // Background Abu-abu Sangat Muda
  static const Color textDark = Color(0xFF1E293B); // Slate/Navy untuk teks utama
  static const Color textGrey = Color(0xFF64748B); // Abu-abu untuk subtitle

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentId = prefs.getInt('id') ?? 1; // Fallback
    });
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    try {
      final tickets = await _ticketService.fetchTickets(_studentId);
      setState(() => _tickets = tickets);
    } catch (e) {
      _showErrorSnackBar('Gagal memuat tiket aduan.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      // Menggunakan Stack untuk Header Gradient
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryOrange)))
          : Stack(
              children: [
                _buildHeaderGradient(),
                RefreshIndicator(
                  onRefresh: _fetchTickets,
                  color: primaryOrange,
                  backgroundColor: Colors.white,
                  edgeOffset: 100, // Mulai refresh di bawah header
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _buildSliverAppBar(),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Padding bawah untuk FAB
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildSummaryDashboard(),
                            const SizedBox(height: 32),
                            _buildSectionHeader(),
                            const SizedBox(height: 16),
                            _tickets.isEmpty ? _buildEmptyState() : _buildTicketList(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- UI COMPONENTS (MODULAR & CLEAN) ---

  Widget _buildHeaderGradient() {
    return Container(
      height: 250, // Tinggi gradien di latar belakang
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryOrange, accentOrange],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 100,
      floating: true,
      pinned: false,
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Pusat Aduan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Suara Anda, Prioritas Kami',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 15, top: 10),
          decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white, size: 22),
            onPressed: () {}, // Akses riwayat cepat
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return Container(
      height: 60,
      width: 180,
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TicketCreatePage(studentId: _studentId)),
          );
          if (result == true) _fetchTickets();
        },
        backgroundColor: primaryOrange,
        elevation: 6,
        highlightElevation: 10,
        splashColor: accentOrange,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text(
          'BUAT ADUAN',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13, letterSpacing: 1),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildSummaryDashboard() {
    int openCount = _tickets.where((t) => t.status == 'Open').length;
    int progressCount = _tickets.where((t) => t.status == 'In-Progress').length;
    int closedCount = _tickets.where((t) => t.status == 'Closed').length;

    return Row(
      children: [
        _buildStatCard('AKTIF', openCount, primaryOrange, Icons.confirmation_num_outlined),
        const SizedBox(width: 15),
        _buildStatCard('PROSES', progressCount, Colors.blue, Icons.sync_rounded),
        const SizedBox(width: 15),
        _buildStatCard('SELESAI', closedCount, Colors.green, Icons.check_circle_outline_rounded),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          // Neumorphic style shadow
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
            BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 2, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: textGrey, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daftar Tiket Anda',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textDark, letterSpacing: -0.5),
        ),
        Text(
          'Urutan: Terbaru',
          style: TextStyle(fontSize: 12, color: primaryOrange, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildTicketList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildTicketCard(_tickets[index]);
      },
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    // Definisi warna berdasarkan status
    Color statusColor;
    if (ticket.status == 'Open') statusColor = primaryOrange;
    else if (ticket.status == 'In-Progress') statusColor = Colors.blue;
    else statusColor = Colors.green;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        // Glassmorphism effect shadow
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketDetailPage(ticketId: ticket.id, studentId: _studentId),
            ),
          );
          if (result == true) _fetchTickets();
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Atas: ID & Prioritas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: bgGrey, borderRadius: BorderRadius.circular(30)),
                    child: Text(
                      '#TKT-${ticket.id.toString().padLeft(4, '0')}',
                      style: TextStyle(color: textGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                  _buildPriorityIndicator(ticket.priority),
                ],
              ),
              const SizedBox(height: 16),
              // Bagian Tengah: Subject & Waktu
              Text(
                ticket.subject,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: textDark, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time_filled_rounded, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    "Dibuat ${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(height: 1, color: Colors.grey.shade100),
              const SizedBox(height: 16),
              // Bagian Bawah: Visual Stepper Status
              _buildVisualStepper(ticket.status, statusColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualStepper(String status, Color color) {
    int currentStep = 0; // default Open
    if (status == 'In-Progress') currentStep = 1;
    if (status == 'Closed') currentStep = 2;

    return Row(
      children: [
        _buildStepItem("Dikirim", Icons.file_upload_rounded, currentStep >= 0, color, true),
        _buildStepLine(currentStep >= 1, color),
        _buildStepItem("Diproses", Icons.engineering_rounded, currentStep >= 1, color, currentStep == 1),
        _buildStepLine(currentStep >= 2, color),
        _buildStepItem("Selesai", Icons.check_circle_rounded, currentStep >= 2, color, false),
      ],
    );
  }

  Widget _buildStepItem(String title, IconData icon, bool isActive, Color activeColor, bool isCurrent) {
    Color itemColor = isActive ? activeColor : Colors.grey.shade300;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.1) : Colors.grey.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? activeColor : Colors.grey.shade200, width: isCurrent ? 2 : 1),
          ),
          child: Icon(icon, size: 18, color: itemColor),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? textDark : Colors.grey.shade400,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive, Color activeColor) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5), // Align with icons
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(String priority) {
    Color col;
    if (priority == 'High') col = Colors.redAccent;
    else if (priority == 'Mid') col = Colors.orangeAccent;
    else col = Colors.greenAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            priority.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: col),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Menggunakan Icon sebagai placeholder (bisa diganti Image asset)
          Icon(Icons.mark_chat_read_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            'Semuanya Terkendali!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'Belum ada tiket aduan baru saat ini.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}