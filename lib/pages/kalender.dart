import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart'; // Sesuaikan path provider kamu
import '../services/attendance_services.dart';
import '../models/attendance_model.dart';
import '../pages/jadwal_mapel.dart';
import 'riwayat_absensi.dart';

const orangeMain = Color.fromARGB(255, 254, 111, 71);
const orangeDeep = Color(0xFFE65100);
const orangeSoft = Color(0xFFFFE0CC);

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
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error loading attendance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.bgWhite,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _header(themeProvider),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: orangeMain))
                      : _calendarCard(themeProvider),
                  const SizedBox(height: 15), // Jarak dikurangi agar lebih rapat
                  _infoCard(themeProvider),
                  const SizedBox(height: 15),
                  _legendCard(themeProvider),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kalender",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Lihat aktivitas hari mu di sekolah dengan mudah.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: themeProvider.subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _calendarCard(ThemeProvider themeProvider) {
    final daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1).weekday;

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            const PositionRectangleDecoration(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _monthSwitcher(themeProvider),
                  const SizedBox(height: 15),
                  _dayHeader(themeProvider),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      thickness: 1, 
                      color: themeProvider.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: daysInMonth + (firstDay % 7),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final int offset = firstDay % 7;
                      if (index < offset) return const SizedBox();
                      final day = index - offset + 1;
                      final date = DateTime(currentMonth.year, currentMonth.month, day);
                      return _dateItem(day: day, date: date, themeProvider: themeProvider);
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

  Widget _monthSwitcher(ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconBtn(Icons.arrow_back_ios_new_rounded, themeProvider, () {
          setState(() => currentMonth = DateTime(currentMonth.year, currentMonth.month - 1));
        }),
        Column(
          children: [
            Text(
              DateFormat('MMMM', 'id').format(currentMonth).toUpperCase(),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
                color: themeProvider.textColor,
              ),
            ),
            Text(
              DateFormat('yyyy').format(currentMonth),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: orangeMain.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        _iconBtn(Icons.arrow_forward_ios_rounded, themeProvider, () {
          setState(() => currentMonth = DateTime(currentMonth.year, currentMonth.month + 1));
        }),
      ],
    );
  }

  Widget _iconBtn(IconData icon, ThemeProvider themeProvider, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: orangeSoft.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: orangeMain, size: 14),
      ),
    );
  }

  Widget _dayHeader(ThemeProvider themeProvider) {
    const days = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];
    return Row(
      children: days.map((e) => Expanded(
        child: Text(
          e,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800,
            fontSize: 10,
            color: e == 'MIN' || e == 'SAB'
                ? Colors.redAccent.withOpacity(0.8)
                : themeProvider.subTextColor.withOpacity(0.5),
          ),
        ),
      )).toList(),
    );
  }

  Widget _dateItem({required int day, required DateTime date, required ThemeProvider themeProvider}) {
    final String dateKey = DateFormat('yyyy-MM-dd').format(date);
    final bool hasAttended = _attendanceData.containsKey(dateKey);
    final String? status = hasAttended ? _attendanceData[dateKey]!.status.toUpperCase() : null;
    final bool isToday = DateUtils.isSameDay(date, today);
    final bool isSelected = selectedDate != null && DateUtils.isSameDay(selectedDate, date);

    Color statusColor = _getStatusColor(status);
    BoxDecoration decoration;
    Color textColor = themeProvider.textColor;

    if (isSelected) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [orangeDeep, orangeMain]),
      );
      textColor = Colors.white;
    } else if (hasAttended) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: statusColor.withOpacity(0.12),
        border: Border.all(color: statusColor, width: 1.5),
      );
      textColor = statusColor;
    } else if (isToday) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: orangeMain, width: 1.5),
      );
      textColor = orangeMain;
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.isDarkMode ? Colors.white10 : const Color(0xFFF5F5F5), width: 1),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => selectedDate = date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          day.toString(),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: isSelected || hasAttended ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'HADIR': return const Color(0xFF4CAF50);
      case 'SAKIT': return const Color(0xFF2196F3);
      case 'IZIN': return const Color(0xFFFFC107);
      case 'ALFA': return const Color(0xFFF44336);
      default: return Colors.grey;
    }
  }

  Widget _legendCard(ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Agar column padat
        children: [
          Row(
            children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: orangeMain, borderRadius: BorderRadius.circular(10))),
              const SizedBox(width: 10),
              Text(
                "Keterangan Status",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: themeProvider.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              mainAxisExtent: 58, // Lebih rapat
              mainAxisSpacing: 10, 
              crossAxisSpacing: 10,
            ),
            children: [
              _legendItem("Hadir", const Color(0xFF4CAF50), Icons.check_circle_rounded, themeProvider),
              _legendItem("Sakit", const Color(0xFF2196F3), Icons.local_hospital_rounded, themeProvider),
              _legendItem("Izin", const Color(0xFFFFC107), Icons.mail_rounded, themeProvider),
              _legendItem("Alfa", const Color(0xFFF44336), Icons.cancel_rounded, themeProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, IconData icon, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            label, 
            style: TextStyle(
              fontFamily: 'Poppins', 
              fontSize: 13, 
              fontWeight: FontWeight.bold, 
              color: themeProvider.textColor
            )
          ),
        ],
      ),
    );
  }

  Widget _infoCard(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: orangeMain.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: orangeMain, size: 18),
              const SizedBox(width: 10),
              Text(
                "Aktivitas & Riwayat", 
                style: TextStyle(
                  fontFamily: 'Poppins', 
                  fontSize: 15, 
                  fontWeight: FontWeight.bold, 
                  color: themeProvider.textColor
                )
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Lihat rincian kehadiran atau jadwal pelajaran kamu.",
            style: TextStyle(fontFamily: 'Poppins', color: themeProvider.subTextColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _actionBtn("Jadwal", themeProvider, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const JadwalMapelPage()));
              }),
              const SizedBox(width: 10),
              _actionBtn("Riwayat", themeProvider, filled: true, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatAbsensiPage()))
                    .then((_) => _loadAttendanceHistory());
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionBtn(String text, ThemeProvider themeProvider, {bool filled = false, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: filled ? orangeMain : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: orangeMain, width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            text, 
            style: TextStyle(
              fontFamily: 'Poppins', 
              color: filled ? Colors.white : orangeMain, 
              fontSize: 13,
              fontWeight: FontWeight.bold
            )
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
      top: -15,
      right: -15,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: orangeSoft.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}