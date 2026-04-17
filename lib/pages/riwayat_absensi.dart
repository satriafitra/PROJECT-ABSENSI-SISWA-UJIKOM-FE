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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: themeProvider.cardColor, // Dinamis
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFFFF5722), size: 18),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
        ),
        title: const Text(
          'KEHADIRAN SISWA',
          style: TextStyle(
            color: Color(0xFFFF5722),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ===== UI FILTER SECTION =====
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedFilter == filters[index];
                IconData filterIcon;
                switch (filters[index]) {
                  case "Hari Ini": filterIcon = Icons.today; break;
                  case "Minggu Ini": filterIcon = Icons.date_range; break;
                  case "Bulan Lalu": filterIcon = Icons.history; break;
                  default: filterIcon = Icons.apps;
                }

                return GestureDetector(
                  onTap: () => setState(() => selectedFilter = filters[index]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF5722) : themeProvider.cardColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isSelected
                          ? [BoxShadow(color: const Color(0xFFFF5722).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                          : [],
                      border: Border.all(
                        color: isSelected ? Colors.transparent : themeProvider.subTextColor.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(filterIcon, size: 16, color: isSelected ? Colors.white : themeProvider.subTextColor),
                        const SizedBox(width: 8),
                        Text(
                          filters[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : themeProvider.textColor,
                            fontWeight: FontWeight.bold,
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
                    child: Text('Belum ada riwayat absensi', style: TextStyle(color: themeProvider.subTextColor)),
                  );
                }

                final filteredList = filterData(snapshot.data!);

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text('Tidak ada data untuk filter ini', style: TextStyle(color: themeProvider.subTextColor)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
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

    final formattedDate = DateTime.tryParse(date) != null
        ? DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.parse(date))
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 10, top: 10),
            child: Row(
              children: [
                Icon(Icons.access_time_filled_rounded, size: 16, color: themeProvider.subTextColor.withOpacity(0.6)),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: themeProvider.subTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: themeProvider.cardColor, // Dinamis
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: themeProvider.isDarkMode 
                ? Border.all(color: Colors.white.withOpacity(0.05)) 
                : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 85,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color.fromARGB(255, 255, 113, 70), Color.fromARGB(255, 255, 66, 8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 34),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shortName,
                              style: const TextStyle(
                                color: Color(0xFFFF4D00),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: themeProvider.isDarkMode ? Colors.white10 : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    kelas,
                                    style: TextStyle(
                                      color: themeProvider.textColor.withOpacity(0.7),
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
                    ],
                  ),
                  Positioned(
                    right: -10,
                    bottom: -5,
                    child: Opacity(
                      opacity: themeProvider.isDarkMode ? 0.8 : 1.0, // Sedikit redup di dark mode
                      child: Transform.scale(
                        scaleX: -1,
                        child: Image.asset(
                          'lib/images/char.png',
                          height: 95,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(), 
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Divider(color: Color(0x11FF7A50), thickness: 1), // Divider lebih samar
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}