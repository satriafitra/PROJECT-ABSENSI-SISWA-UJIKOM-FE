import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class JadwalMapelPage extends StatelessWidget {
  const JadwalMapelPage({super.key});

  // Warna aksen tetap (branding)
  final Color orangeMain = const Color.fromARGB(255, 254, 111, 71);
  final Color orangeDeep = const Color(0xFFE65100);
  final Color orangeSoft = const Color(0xFFFFE0CC);

  @override
  Widget build(BuildContext context) {
    // Memanggil ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        // Latar belakang mengikuti tema
        backgroundColor: themeProvider.bgWhite, 
        appBar: AppBar(
          backgroundColor: themeProvider.bgWhite,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: themeProvider.textColor, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Jadwal Pelajaran",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor, // Teks judul dinamis
              fontSize: 18,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: _buildDayPicker(themeProvider),
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildDailyList('Senin', themeProvider),
            _buildDailyList('Selasa', themeProvider),
            _buildDailyList('Rabu', themeProvider),
            _buildDailyList('Kamis', themeProvider),
            _buildDailyList('Jumat', themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPicker(ThemeProvider themeProvider) {
    return Container(
      height: 45,
      margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
      child: TabBar(
        isScrollable: true,
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        labelColor: Colors.white,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        // Warna teks saat tidak terpilih menyesuaikan mode
        unselectedLabelColor: themeProvider.isDarkMode ? Colors.white38 : Colors.grey[400],
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
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Senin"))),
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Selasa"))),
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Rabu"))),
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Kamis"))),
          Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Jumat"))),
        ],
      ),
    );
  }

  Widget _buildDailyList(String day, ThemeProvider themeProvider) {
    final schedule = _getScheduleData(day);

    if (schedule.isEmpty) {
      return Center(
        child: Text("Tidak ada jadwal", style: TextStyle(color: themeProvider.subTextColor)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      itemCount: schedule.length,
      itemBuilder: (context, index) {
        final item = schedule[index];
        return _buildScheduleCard(item, index == schedule.length - 1, themeProvider);
      },
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> item, bool isLast, ThemeProvider themeProvider) {
    bool isBreak = item['title'].toString().toLowerCase().contains('istirahat');

    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline Indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isBreak ? (themeProvider.isDarkMode ? Colors.white24 : Colors.grey[300]) : orangeMain,
                  shape: BoxShape.circle,
                  border: Border.all(color: themeProvider.cardColor, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: orangeMain.withOpacity(themeProvider.isDarkMode ? 0.1 : 0.2),
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
                // Warna card mengikuti themeProvider
                color: isBreak 
                    ? (themeProvider.isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey[50]) 
                    : themeProvider.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Time Section
                  Container(
                    width: 75,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBreak
                          ? (themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100])
                          : orangeMain.withOpacity(themeProvider.isDarkMode ? 0.1 : 0.08),
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
                            color: orangeMain,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          "s/d",
                          style: TextStyle(fontSize: 9, color: themeProvider.subTextColor.withOpacity(0.5)),
                        ),
                        Text(
                          item['time_end'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: orangeMain,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content Section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
                                  ? themeProvider.subTextColor
                                  : themeProvider.textColor,
                            ),
                          ),
                          if (!isBreak) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.person_outline_rounded,
                                    size: 14,
                                    color: themeProvider.subTextColor.withOpacity(0.6)),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    item['teacher'],
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color: themeProvider.subTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 14,
                                    color: orangeMain.withOpacity(0.7)),
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
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Icon(Icons.coffee_rounded,
                                  size: 16, color: themeProvider.subTextColor.withOpacity(0.3)),
                            ),
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
