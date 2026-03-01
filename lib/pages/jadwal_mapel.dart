import 'package:flutter/material.dart';

class JadwalMapelPage extends StatelessWidget {
  const JadwalMapelPage({super.key});

  final Color orangeMain = const Color.fromARGB(255, 254, 111, 71);
  final Color orangeDeep = const Color(0xFFE65100);
  final Color orangeSoft = const Color(0xFFFFE0CC);
  final Color bgLight = const Color(0xFFFBFBFB);

// Update pada bagian AppBar agar lebih menyatu
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: bgLight,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Jadwal Pelajaran",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
              fontSize: 18,
            ),
          ),
          // Bagian Day Picker diletakkan di bottom AppBar agar lebih rapi
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: _buildDayPicker(),
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildDailyList('Senin'),
            _buildDailyList('Selasa'),
            _buildDailyList('Rabu'),
            _buildDailyList('Kamis'),
            _buildDailyList('Jumat'),
          ],
        ),
      ),
    );
  }

  // Desain Day Picker yang lebih luwes dan tidak kaku
  Widget _buildDayPicker() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TabBar(
        isScrollable: true,
        // Menghilangkan garis bawah standar
        dividerColor: Colors.transparent,
        // Memberi jarak antar tab agar tidak berdekatan
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        // Gaya teks saat terpilih
        labelColor: Colors.white,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        // Gaya teks saat tidak terpilih
        unselectedLabelColor: Colors.grey[400],
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        // Dekorasi background hari yang terpilih (Pill Shape)
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [orangeMain, orangeDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: orangeMain.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Indikator diletakkan di belakang teks (TabIndicatorLocation)
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Senin"))),
          Tab(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Selasa"))),
          Tab(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Rabu"))),
          Tab(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Kamis"))),
          Tab(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Jumat"))),
        ],
      ),
    );
  }

  Widget _buildDailyList(String day) {
    final schedule = _getScheduleData(day);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: schedule.length,
      itemBuilder: (context, index) {
        final item = schedule[index];
        return _buildScheduleCard(item, index == schedule.length - 1);
      },
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> item, bool isLast) {
    bool isBreak = item['title'].toString().toLowerCase().contains('istirahat');

    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline Indicator
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isBreak ? Colors.grey[300] : orangeMain,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: orangeMain.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          // Main Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isBreak ? Colors.white.withOpacity(0.5) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isBreak
                      ? Colors.transparent
                      : Colors.black.withOpacity(0.03),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Time Section
                  Container(
                    width: 80,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isBreak
                          ? Colors.grey[100]
                          : orangeSoft.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['time_start'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: orangeDeep,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "s/d",
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[400]),
                        ),
                        Text(
                          item['time_end'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: orangeMain,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content Section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isBreak
                                  ? Colors.grey[600]
                                  : const Color(0xFF2D3142),
                            ),
                          ),
                          if (!isBreak) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.person,
                                    size: 14,
                                    color: orangeMain.withOpacity(0.5)),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    item['teacher'],
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 14,
                                    color: orangeMain.withOpacity(0.5)),
                                const SizedBox(width: 5),
                                Text(
                                  item['room'],
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    color: orangeMain,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ] else
                            Icon(Icons.coffee_rounded,
                                size: 18, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getScheduleData(String day) {
    switch (day) {
      case 'Senin':
        return [
          {
            'time_start': '06:30',
            'time_end': '07:10',
            'title': 'Upacara',
            'teacher': '-',
            'room': 'Lapangan'
          },
          {
            'time_start': '07:10',
            'time_end': '08:30',
            'title': 'Konsentrasi RPL',
            'teacher': 'Yayat Ruhiyat, S. ST',
            'room': 'XII PPLG-RPL 1'
          },
          {
            'time_start': '08:30',
            'time_end': '09:10',
            'title': 'BK',
            'teacher': 'Ati Melani, M. Pd.',
            'room': 'XII PPLG-RPL 1'
          },
          {
            'time_start': '09:10',
            'time_end': '09:25',
            'title': 'Istirahat 1',
            'teacher': '-',
            'room': '-'
          },
          {
            'time_start': '09:25',
            'time_end': '11:25',
            'title': 'Konsentrasi RPL',
            'teacher': 'Yayat Ruhiyat, S. ST',
            'room': 'XII PPLG-RPL 1'
          },
          {
            'time_start': '11:25',
            'time_end': '12:30',
            'title': 'Istirahat 2',
            'teacher': '-',
            'room': '-'
          },
          {
            'time_start': '12:30',
            'time_end': '15:50',
            'title': 'Pilihan PPLG',
            'teacher': 'Sarah Siti Sumaerah, S. T',
            'room': 'XII PPLG-RPL 1'
          },
        ];
      case 'Selasa':
        return [
          {
            'time_start': '06:30',
            'time_end': '07:10',
            'title': 'Selasa Segar (Senam)',
            'teacher': '-',
            'room': 'Lapangan'
          },
          {
            'time_start': '07:10',
            'time_end': '09:10',
            'title': 'Konsentrasi RPL',
            'teacher': 'Yaqub Hadi Permana, S.T.',
            'room': 'XII PPLG-RPL 1'
          },
          {
            'time_start': '09:10',
            'time_end': '09:25',
            'title': 'Istirahat 1',
            'teacher': '-',
            'room': '-'
          },
          {
            'time_start': '09:25',
            'time_end': '11:25',
            'title': 'Pancasila & RPL',
            'teacher': 'Yaqub Hadi Permana, S.T.',
            'room': 'XII PPLG-RPL 1'
          },
          {
            'time_start': '11:25',
            'time_end': '12:30',
            'title': 'Istirahat 2',
            'teacher': '-',
            'room': '-'
          },
          {
            'time_start': '12:30',
            'time_end': '15:50',
            'title': 'Konsentrasi RPL',
            'teacher': 'A. Luddie Tri S., S.T.',
            'room': 'XII PPLG-RPL 1'
          },
        ];
      case 'Rabu':
        return [
          {
            'time_start': '06:30',
            'time_end': '07:10',
            'title': 'Cahaya Rabu (Literasi)',
            'teacher': '-',
            'room': 'XII PPLG-RPL 1'
          },
          {
            'time_start': '07:10',
            'time_end': '09:10',
            'title': 'Konsentrasi RPL',
            'teacher': 'Fajar M. Sukmawijaya, M.Kom',
            'room': 'XII PPLG-RPL 1'
          },
          {
            'time_start': '09:10',
            'time_end': '09:25',
            'title': 'Istirahat 1',
            'teacher': '-',
            'room': '-'
          },
          {
            'time_start': '09:25',
            'time_end': '11:25',
            'title': 'Konsentrasi RPL & BK',
            'teacher': 'Arianti / Pradita Surya',
            'room': 'XII PPLG-RPL 1'
          },
          {
            'time_start': '11:25',
            'time_end': '12:30',
            'title': 'Istirahat 2',
            'teacher': '-',
            'room': '-'
          },
          {
            'time_start': '12:30',
            'time_end': '15:50',
            'title': 'KIK & B. Inggris',
            'teacher': 'Tini Murtiningsih / Ernis Hendrawati',
            'room': 'XII PPLG-RPL 1'
          },
        ];
      case 'Kamis':
        return [
          {
            'time_start': '06:30',
            'time_end': '07:10',
            'title': 'Kamis Alami (Ekologi)',
            'teacher': '-',
            'room': 'Lapangan'
          },
          {
            'time_start': '07:10',
            'time_end': '09:10',
            'title': 'Konsentrasi RPL',
            'teacher': 'Yaqub Hadi Permana, S.T.',
            'room': 'XII PPLG-RPL 1'
          },
          {
            'time_start': '09:10',
            'time_end': '09:25',
            'title': 'Istirahat 1',
            'teacher': '-',
            'room': '-'
          },
          {
            'time_start': '09:25',
            'time_end': '11:25',
            'title': 'Mulok Jepang & Konsen RPL',
            'teacher': 'Tini Murtiningsih / Rubaetul Adawiyah',
            'room': 'XII PPLG-RPL 1'
          },
          {
            'time_start': '11:25',
            'time_end': '12:30',
            'title': 'Istirahat 2',
            'teacher': '-',
            'room': '-'
          },
          {
            'time_start': '12:30',
            'time_end': '15:50',
            'title': 'B. Indonesia & B. Inggris',
            'teacher': 'Hinda Gumiarti / Ernis Hendrawati',
            'room': 'XII PPLG-RPL 1'
          },
        ];
      case 'Jumat':
        return [
          {
            'time_start': '06:30',
            'time_end': '07:50',
            'title': 'Kerohanian',
            'teacher': '-',
            'room': 'Masjid'
          },
          {
            'time_start': '07:50',
            'time_end': '09:10',
            'title': 'Matematika',
            'teacher': 'Dikdik Juanda, S.Pd.I.',
            'room': 'XII PPLG-RPL 1'
          },
          {
            'time_start': '09:10',
            'time_end': '10:00',
            'title': 'PAB (Agama)',
            'teacher': '-',
            'room': 'XII PPLG-RPL 1'
          },
        ];
      default:
        return [];
    }
  }
}
