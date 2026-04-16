import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/theme_provider.dart';
import '../widgets/schedule_card.dart';
import '../widgets/week_status.dart';
import 'package:absensi_app/pages/inventory.dart';
import '../services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'marketplace.dart';
// Import halaman inventory kamu di sini; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color orangeMain = const Color(0xFFFF7A30);
  final Color orangeSoft = const Color(0xFFFFC09A);
  final Color orangeDark = const Color(0xFFFF3B1F);

  bool _isSubmitting = false;
  File? _selectedImage;

  Future<void> _onRefresh() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 800));
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  // Fungsi navigasi ke Inventory
  void _navigateToInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InventoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final int currentPoints = themeProvider.studentPoints;

    final DateTime now = DateTime.now();
    final String dayNumber = DateFormat('d').format(now);
    final String dayName = DateFormat('EEEE', 'id_ID').format(now);
    final String monthYear = DateFormat('MMMM yyyy', 'id_ID').format(now);
    final String suffix = _getDaySuffix(now.day);

    return Scaffold(
      backgroundColor: themeProvider.bgWhite,
      body: RefreshIndicator(
        color: orangeMain,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              _dateCard(themeProvider, dayNumber, suffix, dayName, monthYear, currentPoints),
              const SizedBox(height: 20),
              
              // --- SEKSI QUICK ACTIONS (NAVIGASI BARU) ---
              _buildQuickActions(themeProvider),
              
              const SizedBox(height: 20),
              _permissionCard(context, themeProvider),
              const SizedBox(height: 25), 
              Text("Today Schedule", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: themeProvider.textColor)),
              const SizedBox(height: 12), 
              _buildScheduleList(dayName),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET NAVIGASI BARU: Quick Actions
  // WIDGET NAVIGASI: Quick Actions
  Widget _buildQuickActions(ThemeProvider themeProvider) {
    return Row(
      children: [
        // Button Ke Inventory (My Vouchers)
        Expanded(
          child: _actionButton(
            themeProvider,
            title: "My Vouchers",
            subtitle: "Cek koleksimu",
            icon: Icons.confirmation_number_rounded,
            color: const Color(0xFF6366F1), // Indigo
            onTap: _navigateToInventory,
          ),
        ),
        const SizedBox(width: 15),
        // Button Ke Marketplace
        Expanded(
          child: _actionButton(
            themeProvider,
            title: "Marketplace",
            subtitle: "Tukar poinmu",
            icon: Icons.storefront_rounded, // Icon Shop/Market
            color: const Color(0xFF10B981), // Emerald Green agar terlihat fresh
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MarketplacePage()),
              );
            },
          ),
        ),
      ],
    );
  }

  // Template Button Action
  Widget _actionButton(ThemeProvider themeProvider, {
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: themeProvider.textColor, fontSize: 14)),
            Text(subtitle, style: TextStyle(color: themeProvider.subTextColor, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _dateCard(ThemeProvider themeProvider, String day, String suffix, String dayName, String monthYear, int points) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, 15),
            color: orangeMain.withOpacity(themeProvider.isDarkMode ? 0.15 : 0.1),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              right: -30, top: -30,
              child: CircleAvatar(radius: 80, backgroundColor: orangeMain.withOpacity(0.05)),
            ),
            Positioned(
              right: 20, bottom: -40,
              child: CircleAvatar(radius: 60, backgroundColor: orangeDark.withOpacity(0.08)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(day, style: TextStyle(fontSize: 55, fontWeight: FontWeight.w900, color: orangeMain, height: 1)),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(suffix, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: themeProvider.textColor)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(dayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(monthYear, style: TextStyle(color: themeProvider.subTextColor, fontSize: 13)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [orangeMain, orangeDark.withOpacity(0.9)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: orangeDark.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(points.toString(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1)),
                                const Text("PTS", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Container(height: 30, width: 1, color: Colors.white.withOpacity(0.3)),
                            const SizedBox(width: 8),
                            const Icon(Icons.stars_rounded, color: Colors.white, size: 24),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 18),
                  const WeekStatus(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FORM IZIN TETAP DI BAWAH ---
  Widget _permissionCard(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: orangeMain.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: orangeMain.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.edit_calendar_rounded, color: orangeMain, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lapor Izin/Sakit?", style: TextStyle(fontWeight: FontWeight.bold, color: themeProvider.textColor, fontSize: 14)),
                Text("Input kehadiran manual", style: TextStyle(fontSize: 11, color: themeProvider.subTextColor)),
              ],
            ),
          ),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () => _showPermissionForm(context, themeProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: orangeMain, 
                foregroundColor: Colors.white, 
                elevation: 0, 
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: const Text("Input", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // --- LOGIK FORM IZIN (TIDAK BERUBAH) ---
  void _showPermissionForm(BuildContext context, ThemeProvider themeProvider) {
    String selectedType = 'Sakit';
    final TextEditingController reasonController = TextEditingController();
    _selectedImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50, height: 5,
                    decoration: BoxDecoration(
                      color: themeProvider.subTextColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text("Form Izin & Sakit", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeProvider.textColor)),
                const SizedBox(height: 8),
                Text("Silakan pilih alasan dan lampirkan bukti foto.", style: TextStyle(fontSize: 14, color: themeProvider.subTextColor)),
                const SizedBox(height: 25),
                Row(
                  children: [
                    _buildChoiceChip(themeProvider, label: "Sakit", isSelected: selectedType == 'Sakit', onSelected: (val) => setModalState(() => selectedType = 'Sakit')),
                    const SizedBox(width: 12),
                    _buildChoiceChip(themeProvider, label: "Izin", isSelected: selectedType == 'Izin', onSelected: (val) => setModalState(() => selectedType = 'Izin')),
                  ],
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: reasonController,
                  maxLines: 2,
                  style: TextStyle(color: themeProvider.textColor),
                  decoration: InputDecoration(
                    hintText: "Keterangan alasan...",
                    filled: true,
                    fillColor: themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                    if (image != null) setModalState(() => _selectedImage = File(image.path));
                  },
                  child: Container(
                    height: 150, width: double.infinity,
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: orangeMain.withOpacity(0.3), width: 2),
                      image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
                    ),
                    child: _selectedImage == null 
                        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_search_rounded, color: orangeMain, size: 40), Text("Pilih Foto Bukti", style: TextStyle(color: themeProvider.subTextColor, fontSize: 12))]) 
                        : null,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: orangeMain, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: _isSubmitting ? null : () async {
                      if (reasonController.text.trim().isEmpty || _selectedImage == null) {
                        QuickAlert.show(context: context, type: QuickAlertType.warning, text: 'Lengkapi data dan foto!');
                        return;
                      }
                      setModalState(() => _isSubmitting = true);
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        int userId = prefs.getInt('user_id') ?? 0;
                        final res = await ApiService.submitManualAttendance(studentId: userId, status: selectedType.toLowerCase(), keterangan: reasonController.text, imageFile: _selectedImage);
                        setModalState(() => _isSubmitting = false);
                        if (res['status'] == true) {
                          if (context.mounted) Navigator.pop(context);
                          QuickAlert.show(context: context, type: QuickAlertType.success, text: res['message'], confirmBtnColor: orangeMain);
                        }
                      } catch (e) {
                        setModalState(() => _isSubmitting = false);
                        QuickAlert.show(context: context, type: QuickAlertType.error, text: 'Terjadi kesalahan sistem');
                      }
                    },
                    child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Kirim Laporan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(ThemeProvider themeProvider, {required String label, required bool isSelected, required Function(bool) onSelected}) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: orangeMain,
      labelStyle: TextStyle(color: isSelected ? Colors.white : themeProvider.textColor, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      showCheckmark: false,
    );
  }

  Widget _buildScheduleList(String dayName) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.fetchJadwalGuru(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
        final List rawData = snapshot.data?['data'] ?? [];
        final List filtered = rawData.where((item) => item['hari'].toString().toLowerCase() == dayName.toLowerCase()).toList();
        if (filtered.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Tidak ada jadwal hari ini.")));
        return Column(
          children: filtered.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ScheduleCard(
              subject: item['mata_pelajaran'] ?? '-',
              teacher: item['guru']['nama'] ?? 'Guru',
              time: item['jam_mulai'] != null ? "${item['jam_mulai'].substring(0, 5)} - ${item['jam_selesai'].substring(0, 5)}" : "-",
            ),
          )).toList(),
        );
      },
    );
  }
}