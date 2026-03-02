import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Wajib
import '../providers/theme_provider.dart'; // Sesuaikan path
import '../widgets/schedule_card.dart';
import '../widgets/week_status.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Palette warna tetap (Orange tidak berubah)
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

  // FUNGSI UNTUK MENAMPILKAN BOTTOM SHEET (Disesuaikan Tema)
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
            color: themeProvider.cardColor, // Dinamis
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
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: themeProvider.subTextColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "Form Izin & Sakit",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor), // Dinamis
                ),
                const SizedBox(height: 8),
                Text(
                  "Silakan pilih alasan dan berikan keterangan singkat.",
                  style: TextStyle(fontSize: 14, color: themeProvider.subTextColor),
                ),
                const SizedBox(height: 25),
                Text("Pilih Alasan",
                    style: TextStyle(fontWeight: FontWeight.bold, color: themeProvider.textColor)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildChoiceChip(
                      themeProvider,
                      label: "Sakit",
                      isSelected: selectedType == 'Sakit',
                      onSelected: (val) => setModalState(() => selectedType = 'Sakit'),
                    ),
                    const SizedBox(width: 12),
                    _buildChoiceChip(
                      themeProvider,
                      label: "Izin",
                      isSelected: selectedType == 'Izin',
                      onSelected: (val) => setModalState(() => selectedType = 'Izin'),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text("Keterangan",
                    style: TextStyle(fontWeight: FontWeight.bold, color: themeProvider.textColor)),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Laporan berhasil dikirim!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeMain,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Kirim Laporan",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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

  Widget _buildChoiceChip(
    ThemeProvider themeProvider, {
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: orangeMain,
      backgroundColor: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : themeProvider.textColor,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    final DateTime now = DateTime.now();
    final String dayNumber = DateFormat('d').format(now);
    final String dayName = DateFormat('EEEE').format(now);
    final String monthYear = DateFormat('MMMM yyyy').format(now);
    final String suffix = _getDaySuffix(now.day);

    return Scaffold(
      backgroundColor: themeProvider.bgWhite, // Gunakan bgWhite dinamis
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor, // Teks judul dinamis
                    ),
                  ),
                  const SizedBox(height: 15),
                  // ScheduleCard dan WeekStatus harus dipastikan juga mengambil warna dari provider di dalamnya
                  const ScheduleCard(
                    subject: "Bahasa Indonesia",
                    teacher: "Pak Pajar",
                    time: "09:00 - 10:00 AM",
                  ),
                  const ScheduleCard(
                    subject: "Matematika",
                    teacher: "Ibu Susi",
                    time: "10:00 - 11:00 AM",
                  ),
                  const ScheduleCard(
                    subject: "Agama",
                    teacher: "Ibu Susi",
                    time: "11:00 - 12:00 PM",
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
          colors: [
            orangeMain.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.1),
            themeProvider.cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: orangeSoft.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.5), 
          width: 1.5
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: orangeMain, borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.edit_calendar_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lapor Izin atau Sakit?",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor)), // Teks Putih/Hitam
                const SizedBox(height: 4),
                Text("Lapor kehadiran manual di sini",
                    style: TextStyle(
                        fontSize: 13, color: themeProvider.subTextColor)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showPermissionForm(context, themeProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeMain,
              foregroundColor: Colors.white,
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
        color: themeProvider.cardColor, // Dinamis
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.05))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Lingkaran Dekorasi Atas
            Positioned(
              right: -60,
              top: -40,
              child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: orangeSoft.withOpacity(themeProvider.isDarkMode ? 0.1 : 0.4))),
            ),
            // Lingkaran Dekorasi Bawah
            Positioned(
              right: -30,
              bottom: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [orangeMain, orangeDark])),
              ),
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
                            TextSpan(
                                text: day,
                                style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w700,
                                    color: orangeDark)),
                            WidgetSpan(
                                child: Transform.translate(
                                    offset: const Offset(0, -25),
                                    child: Text(suffix,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: themeProvider.textColor)))), // Dinamis
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Padding(
                        padding: const EdgeInsets.only(top: 11),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dayName,
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: orangeMain)),
                            const SizedBox(height: 4),
                            Text(monthYear,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: themeProvider.subTextColor)), // Dinamis
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("This Week Status",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textColor)), // Dinamis
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