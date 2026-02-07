import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  _calendarCard(), // Fokus utama: Clean & Luxury
                  const SizedBox(height: 25),
                  _infoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER (Tetap Sama) =================
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

  // ================= CALENDAR CARD (LUXURY DESIGN - UPDATED) =================
  Widget _calendarCard() {
    final daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1).weekday;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: orangeMain.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Stack(
          children: [
            PositionRectangleDecoration(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _monthSwitcher(), // Container orange soft panjang dihapus di sini
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final int offset = firstDay % 7;
                      if (index < offset) return const SizedBox();

                      final day = index - offset + 1;
                      final date = DateTime(currentMonth.year, currentMonth.month, day);

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

  // ================= MONTH SWITCHER (Clean Floating Style) =================
  Widget _monthSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconBtn(Icons.arrow_back_ios_new_rounded, () {
          setState(() {
            currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
          });
        }),
        // Teks dibuat elegan tanpa background panjang
        Column(
          children: [
            Text(
              DateFormat('MMMM', 'id').format(currentMonth).toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w900,
                color: Colors.black87, // Hitam elegan
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, color: orangeMain, size: 16),
      ),
    );
  }

  // ================= DAY HEADER =================
  Widget _dayHeader() {
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
            color: e == 'MIN' ? Colors.redAccent.withOpacity(0.7) : Colors.black26,
          ),
        ),
      )).toList(),
    );
  }

  // ================= DATE ITEM =================
  Widget _dateItem({required int day, required DateTime date}) {
    final bool isToday = DateUtils.isSameDay(date, today);
    final bool isSelected = selectedDate != null && DateUtils.isSameDay(selectedDate, date);
    final bool isPastDate = date.isBefore(DateTime(today.year, today.month, today.day));

    BoxDecoration decoration;
    Color textColor;

    if (isSelected) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [orangeDeep, orangeMain],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: orangeDeep.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      );
      textColor = Colors.white;
    } else if (isToday) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: orangeMain, width: 2),
      );
      textColor = orangeDeep;
    } else if (isPastDate) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFFF8F8F8),
      );
      textColor = Colors.black26;
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF1F1F1), width: 1),
      );
      textColor = Colors.black87;
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
            fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // ================= INFO CARD (Tetap Sama) =================
  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ingin melihat Riwayat Absen atau Kehadiran dan Jadwal ?",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: orangeMain,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _actionBtn("Lihat Jadwal", onTap: () {}),
              const SizedBox(width: 12),
              _actionBtn(
                "Lihat Absen",
                filled: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RiwayatAbsensiPage()),
                  );
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: filled ? orangeMain : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: orangeMain),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: filled ? Colors.white : orangeMain,
              fontWeight: FontWeight.w600,
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
      top: -30,
      right: -30,
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: orangeSoft.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}