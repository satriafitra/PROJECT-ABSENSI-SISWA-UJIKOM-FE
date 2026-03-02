import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Tambahkan ini
import '../providers/theme_provider.dart'; // Sesuaikan path provider kamu

class ScheduleCard extends StatelessWidget {
  final String subject;
  final String teacher;
  final String time;

  const ScheduleCard({
    super.key,
    required this.subject,
    required this.teacher,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    // Memanggil provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // Warna background card dinamis
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF7A30), // Orange tetap orange agar kontras
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _info("Teacher", teacher, themeProvider), // Kirim themeProvider
              const SizedBox(width: 20),
              // Garis pemisah dinamis
              Container(
                height: 28, 
                width: 1, 
                color: themeProvider.isDarkMode ? Colors.white24 : Colors.grey.shade300
              ),
              const SizedBox(width: 20),
              _info("Time", time, themeProvider), // Kirim themeProvider
            ],
          )
        ],
      ),
    );
  }

  // Fungsi pembantu sekarang menerima ThemeProvider
  Widget _info(String label, String value, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: themeProvider.subTextColor, // Abu-abu dinamis
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: themeProvider.textColor, // Hitam atau Putih dinamis
          ),
        ),
      ],
    );
  }
}