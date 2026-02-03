import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import untuk format tanggal
import '../widgets/schedule_card.dart';
import '../widgets/week_status.dart';
import '../widgets/curve_clipper.dart';

const orangeMain = Color(0xFFFF7A30);
const orangeSoft = Color(0xFFFFC09A);
const orangeDark = Color(0xFFFF3B1F);
const textGrey = Color(0xFF9E9E9E);
const textDark = Color(0xFF2E2E2E);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Fungsi untuk mendapatkan akhiran tanggal (st, nd, rd, th)
  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
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
    // Inisialisasi data waktu real-time
    final DateTime now = DateTime.now();
    final String dayNumber = DateFormat('d').format(now); // Tanggal (1, 2, 3...)
    final String dayName = DateFormat('EEEE').format(now); // Nama Hari (Tuesday...)
    final String monthYear = DateFormat('MMMM yyyy').format(now); // Bulan & Tahun
    final String suffix = _getDaySuffix(now.day); // Suffix (st, nd, rd, th)

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _dateCard(dayNumber, suffix, dayName, monthYear),
          const SizedBox(height: 20),
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
    );
  }

  Widget _dateCard(String day, String suffix, String dayName, String monthYear) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(.08),
            ),
          ],
        ),
        child: Stack(
          children: [
            /// BIG SOFT ORANGE CIRCLE
            Positioned(
              right: -60,
              top: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: orangeSoft.withOpacity(.6),
                ),
              ),
            ),

            /// MAIN ORANGE GRADIENT CIRCLE
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

            /// CARD CONTENT
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
                              text: day, // Menggunakan data real-time
                              style: const TextStyle(
                                fontFamily: "Montserrat",
                                fontSize: 56,
                                fontWeight: FontWeight.w700,
                                color: orangeDark,
                              ),
                            ),
                            WidgetSpan(
                              child: Transform.translate(
                                offset: const Offset(0, -25),
                                child: Text(
                                  suffix, // Menggunakan suffix real-time
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
                              dayName, // Nama hari real-time
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: orangeMain,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              monthYear, // Bulan dan tahun real-time
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