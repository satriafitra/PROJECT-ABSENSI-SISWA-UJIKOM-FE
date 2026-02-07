import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/schedule_card.dart';
import '../widgets/week_status.dart';
import '../widgets/curve_clipper.dart'; // Tetap ada jika diperlukan di file lain

const orangeMain = Color(0xFFFF7A30);
const orangeSoft = Color(0xFFFFC09A);
const orangeDark = Color(0xFFFF3B1F);
const textGrey = Color(0xFF9E9E9E);
const textDark = Color(0xFF2E2E2E);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String dayNumber = DateFormat('d').format(now);
    final String dayName = DateFormat('EEEE').format(now);
    final String monthYear = DateFormat('MMMM yyyy').format(now);
    final String suffix = _getDaySuffix(now.day);

    return Scaffold(
      // Menambahkan Scaffold agar background konsisten
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 2, // 👈 kecilkan
            bottom: 20,
          ),
          children: [
            // 1. Card Tanggal & Week Status
            _dateCard(dayNumber, suffix, dayName, monthYear),

            const SizedBox(height: 20),

            // 2. Card Input Manual (Izin/Sakit) - POSISI BARU
            _permissionCard(context),

            const SizedBox(height: 25),

            // Header untuk List View
            const Text(
              "Today Schedule",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 15),

            // 3. List View Jadwal
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
    );
  }

  // Widget Baru: Permission Card
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
          // Icon Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: orangeMain,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.edit_calendar_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),

          // Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ingin Izin atau Sakit?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Lapor kehadiran manual di sini",
                  style: TextStyle(
                    fontSize: 13,
                    color: textDark.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Button Section
          ElevatedButton(
            onPressed: () {
              // Tambahkan navigasi ke form input manual di sini
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
      // Menghapus ClipRRect dan menggunakan Container decoration untuk shadow lebih halus
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.05),
          ),
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
                  color: orangeSoft.withOpacity(.4),
                ),
              ),
            ),
            Positioned(
              right: -30,
              bottom: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [orangeMain, orangeDark],
                  ),
                ),
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
                                color: orangeDark,
                              ),
                            ),
                            WidgetSpan(
                              child: Transform.translate(
                                offset: const Offset(0, -25),
                                child: Text(
                                  suffix,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textDark,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Padding(
                        padding: const EdgeInsets.only(top: 11),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: orangeMain,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              monthYear,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "This Week Status",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
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
