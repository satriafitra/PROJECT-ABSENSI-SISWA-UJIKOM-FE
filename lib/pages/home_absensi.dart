import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/schedule_card.dart';
import '../widgets/week_status.dart';



const orangeMain = Color(0xFFFF7A30);
const orangeSoft = Color(0xFFFFC09A);
const orangeDark = Color(0xFFFF3B1F);
const textGrey = Color(0xFF9E9E9E);
const textDark = Color(0xFF2E2E2E);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // FUNGSI UNTUK MENAMPILKAN BOTTOM SHEET (INPUT MANUAL)
  void _showPermissionForm(BuildContext context) {
    String selectedType = 'Sakit'; // Default value
    final TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar keyboard tidak menutupi input
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Geser ke atas saat keyboard muncul
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Bar (Garis kecil di atas)
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: textGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Form Izin & Sakit",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Silakan pilih alasan dan berikan keterangan singkat.",
                  style: TextStyle(fontSize: 14, color: textGrey),
                ),
                const SizedBox(height: 25),

                // Opsi Pilihan (Sakit / Izin)
                const Text("Pilih Alasan",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildChoiceChip(
                      label: "Sakit",
                      isSelected: selectedType == 'Sakit',
                      onSelected: (val) =>
                          setModalState(() => selectedType = 'Sakit'),
                    ),
                    const SizedBox(width: 12),
                    _buildChoiceChip(
                      label: "Izin",
                      isSelected: selectedType == 'Izin',
                      onSelected: (val) =>
                          setModalState(() => selectedType = 'Izin'),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Input Keterangan
                const Text("Keterangan",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Contoh: Demam tinggi atau keperluan keluarga...",
                    hintStyle: const TextStyle(color: textGrey, fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol Kirim
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Tambahkan logika pengiriman data di sini
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Laporan berhasil dikirim!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeMain,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Kirim Laporan",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
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

  // Widget pembantu untuk Chip Pilihan
  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: orangeMain,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : textDark,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String dayNumber = DateFormat('d').format(now);
    final String dayName = DateFormat('EEEE').format(now);
    final String monthYear = DateFormat('MMMM yyyy').format(now);
    final String suffix = _getDaySuffix(now.day);

    return Scaffold(
      extendBodyBehindAppBar: true, // Gunakan ini agar efek blur terlihat
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dateCard(dayNumber, suffix, dayName, monthYear),
                  const SizedBox(height: 20),
                  _permissionCard(context),
                  const SizedBox(height: 25),
                  const Text(
                    "Today Schedule",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const ScheduleCard(
                    subject: "Bahasa indonesia",
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
                    time: "10:00 - 11:00 AM",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [orangeMain.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: orangeSoft.withOpacity(0.5), width: 1.5),
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
                const Text("Lapor Izin atau Sakit?",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark)),
                const SizedBox(height: 4),
                Text("Lapor kehadiran manual di sini",
                    style: TextStyle(
                        fontSize: 13, color: textDark.withOpacity(0.6))),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showPermissionForm(context), // MEMANGGIL MODAL
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
            child: const Text("Input"),
          ),
        ],
      ),
    );
  }

  Widget _dateCard(
      String day, String suffix, String dayName, String monthYear) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(.05))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: -40,
              child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: orangeSoft.withOpacity(.4))),
            ),
            Positioned(
              right: -30,
              bottom: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
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
                                style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w700,
                                    color: orangeDark)),
                            WidgetSpan(
                                child: Transform.translate(
                                    offset: const Offset(0, -25),
                                    child: Text(suffix,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: textDark)))),
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
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: orangeMain)),
                            const SizedBox(height: 4),
                            Text(monthYear,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: textGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("This Week Status",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textDark)),
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
