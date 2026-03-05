import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/schedule_card.dart';
import '../widgets/week_status.dart';
import '../services/api_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color orangeMain = const Color(0xFFFF7A30);
  final Color orangeSoft = const Color(0xFFFFC09A);
  final Color orangeDark = const Color(0xFFFF3B1F);

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  void _showPermissionForm(BuildContext context, ThemeProvider themeProvider) {
    String selectedType = 'Sakit';
    final TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                Text("Form Izin & Sakit",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeProvider.textColor)),
                const SizedBox(height: 8),
                Text("Silakan pilih alasan dan berikan keterangan singkat.",
                    style: TextStyle(fontSize: 14, color: themeProvider.subTextColor)),
                const SizedBox(height: 25),
                Text("Pilih Alasan", style: TextStyle(fontWeight: FontWeight.bold, color: themeProvider.textColor)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildChoiceChip(themeProvider, label: "Sakit", isSelected: selectedType == 'Sakit', 
                        onSelected: (val) => setModalState(() => selectedType = 'Sakit')),
                    const SizedBox(width: 12),
                    _buildChoiceChip(themeProvider, label: "Izin", isSelected: selectedType == 'Izin', 
                        onSelected: (val) => setModalState(() => selectedType = 'Izin')),
                  ],
                ),
                const SizedBox(height: 25),
                Text("Keterangan", style: TextStyle(fontWeight: FontWeight.bold, color: themeProvider.textColor)),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  style: TextStyle(color: themeProvider.textColor),
                  decoration: InputDecoration(
                    hintText: "Contoh: Demam tinggi...",
                    hintStyle: TextStyle(color: themeProvider.subTextColor, fontSize: 14),
                    filled: true,
                    fillColor: themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan berhasil dikirim!")));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeMain,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("Kirim Laporan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
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
      backgroundColor: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[100],
      labelStyle: TextStyle(color: isSelected ? Colors.white : themeProvider.textColor, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final DateTime now = DateTime.now();
    
    // Format tanggal untuk Header
    final String dayNumber = DateFormat('d').format(now);
    final String dayName = DateFormat('EEEE', 'id_ID').format(now); // Kamis
    final String monthYear = DateFormat('MMMM yyyy', 'id_ID').format(now);
    final String suffix = _getDaySuffix(now.day);

    return Scaffold(
      backgroundColor: themeProvider.bgWhite,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dateCard(themeProvider, dayNumber, suffix, dayName, monthYear),
                  const SizedBox(height: 20),
                  _permissionCard(context, themeProvider),
                  const SizedBox(height: 25),
                  Text(
                    "Today Schedule",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: themeProvider.textColor),
                  ),
                  const SizedBox(height: 15),
                  
                  // LOGIKA FILTERING JADWAL
                  FutureBuilder<Map<String, dynamic>>(
                    future: ApiService.fetchJadwalGuru(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A30)));
                      }

                      if (snapshot.hasError || snapshot.data?['status'] == false) {
                        return Center(child: Text(snapshot.data?['message'] ?? "Gagal memuat jadwal", 
                          style: TextStyle(color: themeProvider.subTextColor)));
                      }

                      final List rawData = snapshot.data?['data'] ?? [];

                      // PROSES FILTERING: Hanya hari ini & Belum lewat jamnya
                      final List filteredJadwal = rawData.where((item) {
                        // 1. Cek Hari (Sesuaikan dengan string di DB Anda)
                        bool isSameDay = item['hari'].toString().toLowerCase() == dayName.toLowerCase();

                        // 2. Cek Jam (Opsional: hapus blok ini jika ingin jadwal seharian tetap muncul)
                        final String jamSelesaiStr = item['jam_selesai']; // format "14:00:00"
                        final parts = jamSelesaiStr.split(':');
                        final limitTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
                        bool isNotExpired = limitTime.isAfter(now);

                        return isSameDay && isNotExpired;
                      }).toList();

                      if (filteredJadwal.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text("Tidak ada jadwal tersisa untuk hari ini.", 
                              style: TextStyle(color: themeProvider.subTextColor, fontStyle: FontStyle.italic)),
                          ),
                        );
                      }

                      return Column(
                        children: filteredJadwal.map((item) {
                          return ScheduleCard(
                            subject: item['mata_pelajaran'] ?? '-',
                            teacher: item['guru']['nama'] ?? 'Guru',
                            time: "${item['jam_mulai'].substring(0, 5)} - ${item['jam_selesai'].substring(0, 5)}",
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionCard(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [orangeMain.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.1), themeProvider.cardColor],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: orangeSoft.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: orangeMain, borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lapor Izin atau Sakit?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: themeProvider.textColor)),
                const SizedBox(height: 4),
                Text("Lapor kehadiran manual di sini", style: TextStyle(fontSize: 13, color: themeProvider.subTextColor)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showPermissionForm(context, themeProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeMain, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text("Input"),
          ),
        ],
      ),
    );
  }

  Widget _dateCard(ThemeProvider themeProvider, String day, String suffix, String dayName, String monthYear) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(blurRadius: 20, offset: const Offset(0, 10), color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.05))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -60, top: -40,
              child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: orangeSoft.withOpacity(themeProvider.isDarkMode ? 0.1 : 0.4))),
            ),
            Positioned(
              right: -30, bottom: -40,
              child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [orangeMain, orangeDark]))),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: day, style: TextStyle(fontSize: 56, fontWeight: FontWeight.w700, color: orangeDark)),
                            WidgetSpan(child: Transform.translate(offset: const Offset(0, -25), child: Text(suffix, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeProvider.textColor)))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Padding(
                        padding: const EdgeInsets.only(top: 11),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dayName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: orangeMain)),
                            const SizedBox(height: 4),
                            Text(monthYear, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: themeProvider.subTextColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("This Week Status", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: themeProvider.textColor)),
                  const SizedBox(height: 10),
                  const WeekStatus(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}