import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/attendance_services.dart';
import '../models/attendance_model.dart';
import '../pages/jadwal_mapel.dart';
import 'riwayat_absensi.dart';

const orangeMain = Color.fromARGB(255, 254, 111, 71);
const orangeDeep = Color(0xFFE65100);
const orangeSoft = Color(0xFFFFE0CC);
const orangeLight = Color(0xFFFFF3E0);

class KalenderPage extends StatefulWidget {
  const KalenderPage({super.key});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  DateTime currentMonth = DateTime.now();
  DateTime? selectedDate;
  final DateTime today = DateTime.now();

  Map<String, AttendanceModel> _attendanceData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    try {
      final data = await AttendanceService.fetchHistory();
      Map<String, AttendanceModel> tempMap = {};

      for (var item in data) {
        DateTime? parsedDate = DateTime.tryParse(item.date);
        if (parsedDate != null) {
          String key = DateFormat('yyyy-MM-dd').format(parsedDate);
          tempMap[key] = item;
        }
      }

      setState(() {
        _attendanceData = tempMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading attendance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 25),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: orangeMain))
                      : _calendarCard(),
                  const SizedBox(height: 25),
                  _infoCard(), // Container dengan Outline Orange
                  const SizedBox(height: 20),
                  _legendCard(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Kalender",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Lihat aktivitas hari mu di sekolah, semoga hari kamu menyenangkan !!",
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _calendarCard() {
    final daysInMonth =
        DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1).weekday;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Stack(
          children: [
            const PositionRectangleDecoration(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _monthSwitcher(),
                  const SizedBox(height: 25),
                  _dayHeader(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Opacity(
                      opacity: 0.05,
                      child: Divider(thickness: 1, color: Colors.black),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: daysInMonth + (firstDay % 7),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final int offset = firstDay % 7;
                      if (index < offset) return const SizedBox();

                      final day = index - offset + 1;
                      final date =
                          DateTime(currentMonth.year, currentMonth.month, day);

                      return _dateItem(day: day, date: date);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconBtn(Icons.arrow_back_ios_new_rounded, () {
          setState(() {
            currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
          });
        }),
        Column(
          children: [
            Text(
              DateFormat('MMMM', 'id').format(currentMonth).toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            Text(
              DateFormat('yyyy').format(currentMonth),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                letterSpacing: 3,
                color: orangeMain.withOpacity(0.6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        _iconBtn(Icons.arrow_forward_ios_rounded, () {
          setState(() {
            currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
          });
        }),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: orangeSoft.withOpacity(0.5), width: 1),
        ),
        child: Icon(icon, color: orangeMain, size: 16),
      ),
    );
  }

  Widget _dayHeader() {
    const days = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];
    return Row(
      children: days
          .map((e) => Expanded(
                child: Text(
                  e,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    color: e == 'MIN' || e == 'SAB'
                        ? Colors.redAccent.withOpacity(0.7)
                        : Colors.black26,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _dateItem({required int day, required DateTime date}) {
    final String dateKey = DateFormat('yyyy-MM-dd').format(date);
    final bool hasAttended = _attendanceData.containsKey(dateKey);
    final String? status =
        hasAttended ? _attendanceData[dateKey]!.status.toUpperCase() : null;

    final bool isToday = DateUtils.isSameDay(date, today);
    final bool isSelected =
        selectedDate != null && DateUtils.isSameDay(selectedDate, date);

    Color statusColor = _getStatusColor(status);

    BoxDecoration decoration;
    Color textColor = Colors.black87;

    if (isSelected) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [orangeDeep, orangeMain],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
      textColor = Colors.white;
    } else if (hasAttended) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: statusColor.withOpacity(0.08),
        border: Border.all(color: statusColor, width: 2),
      );
      textColor = statusColor;
    } else if (isToday) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: orangeMain, width: 1),
      );
      textColor = orangeDeep;
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF5F5F5), width: 1),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => selectedDate = date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          day.toString(),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight:
                isSelected || hasAttended ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'HADIR':
        return const Color(0xFF4CAF50);
      case 'SAKIT':
        return const Color(0xFF2196F3);
      case 'IZIN':
        return const Color(0xFFFFC107);
      case 'ALFA':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  Widget _legendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: orangeMain,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Keterangan Status",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 65,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            children: [
              _legendItem(
                  "Hadir", const Color(0xFF4CAF50), Icons.check_circle_rounded),
              _legendItem("Sakit", const Color(0xFF2196F3),
                  Icons.local_hospital_rounded),
              _legendItem("Izin", const Color(0xFFFFC107), Icons.mail_rounded),
              _legendItem(
                  "Alfa", const Color(0xFFF44336), Icons.cancel_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4F5D75),
            ),
          ),
        ],
      ),
    );
  }

  // --- BAGIAN YANG DI PERBARUI (INFO CARD DENGAN OUTLINE ORANGE) ---
  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        // Memberikan outline orange yang elegan
        border: Border.all(
          color: orangeMain.withOpacity(0.4), 
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: orangeMain.withOpacity(0.05), 
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: orangeSoft.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: orangeMain,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Aktivitas & Riwayat",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Gunakan tombol di bawah untuk melihat rincian kehadiran atau jadwal pelajaran kamu.",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black54,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _actionBtn(
                "Jadwal",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JadwalMapelPage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _actionBtn(
                "Riwayat",
                filled: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RiwayatAbsensiPage(),
                    ),
                  ).then((_) => _loadAttendanceHistory());
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionBtn(String text, {bool filled = false, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: filled ? orangeMain : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: orangeMain, width: 1.5),
            boxShadow: filled ? [
              BoxShadow(
                color: orangeMain.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: filled ? Colors.white : orangeMain,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class PositionRectangleDecoration extends StatelessWidget {
  const PositionRectangleDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -20,
      right: -20,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: orangeSoft.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}