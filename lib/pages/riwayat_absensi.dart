import 'package:flutter/material.dart';
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
  String selectedFilter = "Semua"; // Default filter
  final List<String> filters = ["Semua", "Minggu Ini", "Bulan Lalu"];

  // Fungsi Logika Filter
  List<AttendanceModel> filterData(List<AttendanceModel> data) {
    DateTime now = DateTime.now();
    
    if (selectedFilter == "Minggu Ini") {
      // Cari awal minggu (Senin)
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      
      return data.where((item) {
        DateTime? itemDate = DateTime.tryParse(item.date);
        return itemDate != null && itemDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
      }).toList();
    } 
    
    else if (selectedFilter == "Bulan Lalu") {
      // Cari awal dan akhir bulan lalu
      DateTime firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
      DateTime lastDayLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
      
      return data.where((item) {
        DateTime? itemDate = DateTime.tryParse(item.date);
        return itemDate != null && 
               itemDate.isAfter(firstDayLastMonth.subtract(const Duration(seconds: 1))) && 
               itemDate.isBefore(lastDayLastMonth.add(const Duration(seconds: 1)));
      }).toList();
    }
    
    return data; // "Semua"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
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
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = filters[index];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF5722) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF5722).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          index == 0 ? Icons.apps : index == 1 ? Icons.date_range : Icons.history,
                          size: 16,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          filters[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
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
                  return const Center(
                    child: Text(
                      'Belum ada riwayat absensi',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Terapkan fungsi filter
                final filteredList = filterData(snapshot.data!);

                if (filteredList.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada data untuk filter ini',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return AttendanceItem(
                      status: filteredList[index].status,
                      date: filteredList[index].date,
                      guruName: filteredList[index].guruName ?? '-',
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

  const AttendanceItem({
    super.key,
    required this.status,
    required this.date,
    required this.guruName,
  });

  @override
  Widget build(BuildContext context) {
    final shortName = getShortName(Session.studentName);
    final kelas = Session.studentClass ?? '-';

    final formattedDate = DateTime.tryParse(date) != null
        ? DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
            .format(DateTime.parse(date))
        : date;

    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailAbsensiPage(
              date: date,
              status: status,
              guruName: guruName,
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
                const Icon(Icons.access_time_filled_rounded,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey.shade600,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 85,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF8A65), Color(0xFFFF5722)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            bottomLeft: Radius.circular(25),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    kelas,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(status: status.toUpperCase()),
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
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Divider(color: Color(0x33FF7A50), thickness: 1),
          ),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'HADIR':
        bgColor = const Color(0xFFE8F5E9);
        textColor = Colors.green.shade700;
        break;
      case 'SAKIT':
        bgColor = const Color(0xFFFFFDE7);
        textColor = Colors.orange.shade800;
        break;
      default:
        bgColor = const Color(0xFFFFEBEE);
        textColor = Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.1)),
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