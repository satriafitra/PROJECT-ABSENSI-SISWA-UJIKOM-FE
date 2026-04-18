import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/theme_provider.dart';
import '../services/attendance_services.dart';
import '../models/attendance_model.dart';
import 'package:intl/intl.dart';

class ChartAbsensiPage extends StatefulWidget {
  const ChartAbsensiPage({super.key});

  @override
  State<ChartAbsensiPage> createState() => _ChartAbsensiPageState();
}

class _ChartAbsensiPageState extends State<ChartAbsensiPage> {
  // Warna Utama
  final Color hadirColor = const Color(0xFF10B981); // Hijau
  final Color sakitColor = const Color(0xFFF59E0B); // Kuning
  final Color izinColor = const Color(0xFF3B82F6); // Biru
  final Color alpaColor = const Color(0xFFEF4444); // Merah

  int touchedIndex = -1;

  Map<String, int> _calculateStats(List<AttendanceModel> data) {
    int hadir = 0;
    int sakit = 0;
    int izin = 0;
    int alpa = 0;

    for (var item in data) {
      String status = item.status.toUpperCase();
      if (status == 'HADIR') hadir++;
      else if (status == 'SAKIT') sakit++;
      else if (status == 'IZIN') izin++;
      else alpa++; // Telat/Alpa
    }

    return {'Hadir': hadir, 'Sakit': sakit, 'Izin': izin, 'Alpa': alpa};
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.bgWhite,
      body: Column(
        children: [
          // HEADER KUSTOM
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                      'Statistik\nKehadiran',
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
                        'Analisis data absensi kamu',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.pie_chart_rounded, size: 100, color: Colors.white.withOpacity(0.2)),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<AttendanceModel>>(
              future: AttendanceService.fetchHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A30)));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Belum ada data absensi untuk dianalisis"));
                }

                final stats = _calculateStats(snapshot.data!);
                final total = stats.values.fold(0, (sum, val) => sum + val);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // KARTU PIE CHART
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: themeProvider.cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Persentase Kehadiran",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                          touchedIndex = -1;
                                          return;
                                        }
                                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                  sections: _showingSections(stats, total, themeProvider),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // INDIKATOR WARNA
                            Wrap(
                              spacing: 15,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                _indicator(hadirColor, "Hadir (${stats['Hadir']})", themeProvider),
                                _indicator(sakitColor, "Sakit (${stats['Sakit']})", themeProvider),
                                _indicator(izinColor, "Izin (${stats['Izin']})", themeProvider),
                                _indicator(alpaColor, "Alfa (${stats['Alpa']})", themeProvider),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // KARTU RINGKASAN
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: themeProvider.cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ringkasan Kedisiplinan",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            _buildSummaryItem("Total Pertemuan", total.toString(), Icons.event_note, Colors.blue, themeProvider),
                            const Divider(height: 30),
                            _buildSummaryItem("Kehadiran Sempurna", "${((stats['Hadir']! / (total == 0 ? 1 : total)) * 100).toStringAsFixed(1)}%", Icons.verified_rounded, hadirColor, themeProvider),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections(Map<String, int> stats, int total, ThemeProvider themeProvider) {
    if (total == 0) return [];
    
    return [
      _buildSection(0, stats['Hadir']!, total, hadirColor, "Hadir"),
      _buildSection(1, stats['Sakit']!, total, sakitColor, "Sakit"),
      _buildSection(2, stats['Izin']!, total, izinColor, "Izin"),
      _buildSection(3, stats['Alpa']!, total, alpaColor, "Alfa"),
    ];
  }

  PieChartSectionData _buildSection(int index, int value, int total, Color color, String title) {
    final isTouched = index == touchedIndex;
    final fontSize = isTouched ? 18.0 : 12.0;
    final radius = isTouched ? 60.0 : 50.0;
    final percentage = (value / total * 100).toStringAsFixed(1);

    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: value > 0 ? '$percentage%' : '',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
      ),
    );
  }

  Widget _indicator(Color color, String text, ThemeProvider themeProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: themeProvider.textColor, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color, ThemeProvider themeProvider) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(title, style: TextStyle(color: themeProvider.subTextColor, fontSize: 14)),
        ),
        Text(value, style: TextStyle(color: themeProvider.textColor, fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
