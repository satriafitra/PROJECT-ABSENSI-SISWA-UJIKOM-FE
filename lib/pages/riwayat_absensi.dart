import 'package:flutter/material.dart';

const orangeMain = Color(0xFFFF7A30);
const orangeSoft = Color(0xFFFFC09A);
const orangeDark = Color(0xFFFF3B1F);
const textGrey = Color(0xFF9E9E9E);

class RiwayatAbsensiPage extends StatelessWidget {
  const RiwayatAbsensiPage({super.key});

  // Dummy data absensi
  final List<Map<String, String>> dummyAbsensi = const [
    {"nama": "Muhammad Jannah", "kelas": "9.A", "keterangan": "Hadir"},
    {"nama": "Siti Aminah", "kelas": "9.B", "keterangan": "Sakit"},
    {"nama": "Budi Santoso", "kelas": "9.C", "keterangan": "Alpa"},
    {"nama": "Lia Putri", "kelas": "9.A", "keterangan": "Hadir"},
    {"nama": "Ahmad Fauzi", "kelas": "9.B", "keterangan": "Hadir"},
    {"nama": "Dewi Anggraini", "kelas": "9.C", "keterangan": "Sakit"},
    {"nama": "Rizki Ramadhan", "kelas": "9.A", "keterangan": "Hadir"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: orangeMain,
        title: const Text(
          "Riwayat Absensi",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: dummyAbsensi.length,
        itemBuilder: (context, index) {
          final item = dummyAbsensi[index];
          Color statusColor;
          if (item['keterangan'] == 'Hadir') {
            statusColor = Colors.green;
          } else if (item['keterangan'] == 'Sakit') {
            statusColor = Colors.orange;
          } else {
            statusColor = Colors.redAccent;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: orangeSoft, width: 1),
            ),
            child: Row(
              children: [
                // Circle Avatar with initials
                CircleAvatar(
                  radius: 28,
                  backgroundColor: orangeSoft,
                  child: Text(
                    item['nama']!.split(' ').map((e) => e[0]).take(2).join(),
                    style: const TextStyle(
                        color: orangeMain,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                // Info nama & kelas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nama']!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Kelas: ${item['kelas']!}",
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['keterangan']!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
