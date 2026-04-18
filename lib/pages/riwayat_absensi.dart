import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Wajib untuk tema
import '../providers/theme_provider.dart'; // Sesuaikan path provider Anda
import '../utils/session.dart';
import '../services/attendance_services.dart';
import '../models/attendance_model.dart';
import 'detail_absensi_page.dart';
import 'package:intl/intl.dart';

/// Helper untuk nama pendek
String getShortName(String? fullName) {
  if (fullName == null || fullName.isEmpty) return '-';
  final parts = fullName.trim().split(' ');
  if (parts.length == 1) return parts[0];
  return '${parts[0]} ${parts[1]}';
}

class RiwayatAbsensiPage extends StatefulWidget {
  const RiwayatAbsensiPage({super.key});

  @override
  State<RiwayatAbsensiPage> createState() => _RiwayatAbsensiPageState();
}

class _RiwayatAbsensiPageState extends State<RiwayatAbsensiPage> {
  String selectedFilter = "Semua";
  final List<String> filters = ["Semua", "Hari Ini", "Minggu Ini", "Bulan Lalu"];

  List<AttendanceModel> filterData(List<AttendanceModel> data) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    if (selectedFilter == "Hari Ini") {
      return data.where((item) {
        DateTime? itemDate = DateTime.tryParse(item.date);
        if (itemDate == null) return false;
        return itemDate.year == today.year &&
               itemDate.month == today.month &&
               itemDate.day == today.day;
      }).toList();
    } 
    else if (selectedFilter == "Minggu Ini") {
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      return data.where((item) {
        DateTime? itemDate = DateTime.tryParse(item.date);
        return itemDate != null && itemDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
      }).toList();
    } 
    else if (selectedFilter == "Bulan Lalu") {
      DateTime firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
      DateTime lastDayLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
      return data.where((item) {
        DateTime? itemDate = DateTime.tryParse(item.date);
        return itemDate != null && 
               itemDate.isAfter(firstDayLastMonth.subtract(const Duration(seconds: 1))) && 
               itemDate.isBefore(lastDayLastMonth.add(const Duration(seconds: 1)));
      }).toList();
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.bgWhite, // Dinamis
      body: Column(
        children: [
          // ===== CUSTOM HEADER DENGAN GAMBAR =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7A30), Color(0xFFFF3B1F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF3B1F).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Riwayat\nAbsensi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Pantau kehadiranmu disini',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                // Gambar Karakter Pindah Kesini!
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Transform.scale(
                      scaleX: -1, // Flip jika diperlukan sesuai keinginan desain
                      child: Image.asset(
                        'lib/images/char.png',
                        height: 140,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(), 
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // ===== UI FILTER SECTION =====
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedFilter == filters[index];
                IconData filterIcon;
                switch (filters[index]) {
                  case "Hari Ini": filterIcon = Icons.today_rounded; break;
                  case "Minggu Ini": filterIcon = Icons.date_range_rounded; break;
                  case "Bulan Lalu": filterIcon = Icons.history_rounded; break;
                  default: filterIcon = Icons.apps_rounded;
                }

                return GestureDetector(
                  onTap: () => setState(() => selectedFilter = filters[index]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFFFF5722) 
                          : (themeProvider.isDarkMode ? Colors.white10 : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: isSelected
                          ? [BoxShadow(color: const Color(0xFFFF5722).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(filterIcon, size: 18, color: isSelected ? Colors.white : themeProvider.subTextColor),
                        const SizedBox(width: 8),
                        Text(
                          filters[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : themeProvider.textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ===== LIST DATA SECTION =====
          Expanded(
            child: FutureBuilder<List<AttendanceModel>>(
              future: AttendanceService.fetchHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off_rounded, size: 60, color: themeProvider.subTextColor.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('Belum ada riwayat absensi', style: TextStyle(color: themeProvider.subTextColor, fontSize: 16)),
                      ],
                    ),
                  );
                }

                final filteredList = filterData(snapshot.data!);

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 60, color: themeProvider.subTextColor.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('Tidak ada data untuk filter ini', style: TextStyle(color: themeProvider.subTextColor, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return AttendanceItem(
                      status: filteredList[index].status,
                      date: filteredList[index].date,
                      guruName: filteredList[index].guruName ?? '-',
                      imageUrl: filteredList[index].image,
                      themeProvider: themeProvider, // Pass theme
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceItem extends StatelessWidget {
  final String status;
  final String date;
  final String guruName;
  final String? imageUrl;
  final ThemeProvider themeProvider;

  const AttendanceItem({
    super.key,
    required this.status,
    required this.date,
    required this.guruName,
    this.imageUrl,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final shortName = getShortName(Session.studentName);
    final kelas = Session.studentClass ?? '-';

    final DateTime? parsedDate = DateTime.tryParse(date);
    final String dayNumber = parsedDate != null ? DateFormat('dd').format(parsedDate) : '-';
    final String monthName = parsedDate != null ? DateFormat('MMM').format(parsedDate) : '-';
    final String dayNameAndYear = parsedDate != null 
        ? DateFormat('EEEE, yyyy', 'id_ID').format(parsedDate) 
        : date;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailAbsensiPage(
              date: date,
              status: status,
              guruName: guruName,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          border: themeProvider.isDarkMode ? Border.all(color: Colors.white10) : null,
        ),
        child: Row(
          children: [
            // TANGGAL (BLOK KIRI ORANGE)
            Container(
              width: 65,
              height: 75,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A30), Color(0xFFFF3B1F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3B1F).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    monthName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // INFO SISWA (TENGAH)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayNameAndYear,
                    style: TextStyle(
                      color: themeProvider.subTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shortName,
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode ? Colors.white10 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          kelas,
                          style: TextStyle(
                            color: themeProvider.textColor.withOpacity(0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: status.toUpperCase(), isDarkMode: themeProvider.isDarkMode),
                    ],
                  ),
                ],
              ),
            ),
            
            // ICON PANAH KE KANAN
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.white10 : Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: themeProvider.subTextColor.withOpacity(0.7),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isDarkMode;
  const StatusBadge({super.key, required this.status, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'HADIR':
        bgColor = isDarkMode ? Colors.green.withOpacity(0.15) : const Color(0xFFE8F5E9);
        textColor = isDarkMode ? Colors.greenAccent : Colors.green.shade700;
        break;
      case 'SAKIT':
        bgColor = isDarkMode ? Colors.orange.withOpacity(0.15) : const Color(0xFFFFFDE7);
        textColor = isDarkMode ? Colors.orangeAccent : Colors.orange.shade800;
        break;
      default:
        bgColor = isDarkMode ? Colors.red.withOpacity(0.15) : const Color(0xFFFFEBEE);
        textColor = isDarkMode ? Colors.redAccent : Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}