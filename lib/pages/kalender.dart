import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'riwayat_absensi.dart';

const orangeMain = Color.fromARGB(255, 254, 111, 71);
const orangeSoft = Color(0xFFFFE0CC);

class KalenderPage extends StatefulWidget {
  const KalenderPage({super.key});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  DateTime currentMonth = DateTime.now();
  DateTime? selectedDate;

  // contoh status absensi
  final Map<String, String> absensi = {
    '2026-02-01': 'H',
    '2026-02-02': 'S',
    '2026-02-03': 'A',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /// 🔥 KONTEN BISA SCROLL
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 20),
                  _calendarCard(),
                  const SizedBox(height: 20),
                  _infoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
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

  // ================= CALENDAR CARD =================
  Widget _calendarCard() {
    final daysInMonth =
        DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1).weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          _monthSwitcher(),
          const SizedBox(height: 16), // Jarak ke Day Header
          _dayHeader(),
          const SizedBox(height: 12), // 🔥 JARAK DIPERECIL ke Grid Tanggal agar lebih rapat
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero, // Pastikan tidak ada padding tambahan
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstDay - 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8, // 🔥 JARAK ANTAR BARIS TANGGAL diperapat
              crossAxisSpacing: 8, // 🔥 JARAK ANTAR KOLOM TANGGAL diperapat
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              if (index < firstDay - 1) return const SizedBox();

              final day = index - firstDay + 2;
              final date = DateTime(currentMonth.year, currentMonth.month, day);
              final dateKey = DateFormat('yyyy-MM-dd').format(date);

              return _dateItem(
                day: day,
                date: date,
                status: absensi[dateKey],
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= MONTH SWITCHER =================
  Widget _monthSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconBtn(Icons.chevron_left, () {
          setState(() {
            currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
          });
        }),
        Text(
          DateFormat('MMMM yyyy', 'id').format(currentMonth),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20, // Sedikit disesuaikan agar rapi
            fontWeight: FontWeight.bold,
          ),
        ),
        _iconBtn(Icons.chevron_right, () {
          setState(() {
            currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
          });
        }),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: orangeSoft,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        iconSize: 20,
        icon: Icon(icon, color: orangeMain),
        onPressed: onTap,
      ),
    );
  }

  // ================= DAY HEADER =================
  Widget _dayHeader() {
    const days = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    return Row(
      children: days
          .map(
            (e) => Expanded(
              child: Text(
                e,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black38, // Warna diperhalus agar rapi
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ================= DATE ITEM (BULAT) =================
  Widget _dateItem({
    required int day,
    required DateTime date,
    String? status,
  }) {
    bool isSelected =
        selectedDate != null && DateUtils.isSameDay(selectedDate, date);

    Color bgColor = Colors.white;
    Color textColor = Colors.black;
    String text = day.toString();

    // Logic Warna Berdasarkan Status
    if (status == 'H') {
      bgColor = orangeMain;
      text = 'H';
      textColor = Colors.white;
    } else if (status == 'S') {
      bgColor = Colors.orange;
      text = 'S';
      textColor = Colors.white;
    } else if (status == 'A') {
      bgColor = Colors.redAccent;
      text = 'A';
      textColor = Colors.white;
    }

    // Override jika tanggal dipilih manual
    if (isSelected) {
      bgColor = orangeMain;
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(
            color: isSelected ? orangeMain : Colors.grey.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // ================= INFO CARD =================
  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ingin melihat Riwayat Absen atau Kehadiran dan Jadwal ?",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: orangeMain,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _actionBtn("Lihat Jadwal", onTap: () {
                // Navigasi Jadwal
              }),
              const SizedBox(width: 12),
              _actionBtn("Lihat Absen", filled: true, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RiwayatAbsensiPage(),
                  ),
                );
              }),
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