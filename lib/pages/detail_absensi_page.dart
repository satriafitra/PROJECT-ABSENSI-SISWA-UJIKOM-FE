import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/session.dart';
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart'; // Pastikan path benar
import '../services/api_services.dart';

class DetailAbsensiPage extends StatelessWidget {
  final String date;
  final String status;
  final String guruName;
  final String? imageUrl;

  const DetailAbsensiPage({
    super.key,
    required this.date,
    required this.status,
    required this.guruName,
    this.imageUrl,
  });

  // Skema Warna Premium Sunset Orange
  static const Color primaryOrange = Color(0xFFF4511E);
  static const Color lightOrangeBg = Color(0xFFFFF3E0);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final formattedDate = DateTime.tryParse(date) != null
        ? DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.parse(date))
        : date;

    String initials = (Session.studentName ?? 'S').split(' ').map((e) => e[0]).take(2).join();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          // Background Gradient Header
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [const Color(0xFFBF360C), const Color(0xFFE65100)] // Lebih redup saat dark
                  : [primaryOrange, const Color(0xFFFF8F00)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -50,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.white.withOpacity(0.07),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: -30,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.07),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'DETAIL ABSENSI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), 
                    ],
                  ),
                ),

                // User Profile Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: isDark ? const Color(0xFF333333) : Colors.white,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: primaryOrange,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        Session.studentName?.toUpperCase() ?? '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Container Utama
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 15),
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 10),
                    decoration: BoxDecoration(
                      color: themeProvider.bgWhite, // Adaptif (Putih / Abu gelap)
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                      boxShadow: isDark ? [] : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        )
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('INFORMASI AKADEMIK', isDark),
                          _buildModernCard(
                            label: 'Kelas',
                            value: Session.studentClass ?? '-',
                            icon: Icons.class_outlined,
                            isDark: isDark,
                            textColor: themeProvider.textColor,
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle('RINCIAN KEHADIRAN', isDark),
                          _buildModernCard(
                            label: 'Tanggal',
                            value: formattedDate,
                            icon: Icons.calendar_today_outlined,
                            isDark: isDark,
                            textColor: themeProvider.textColor,
                          ),
                          _buildModernCard(
                            label: 'Status Absensi',
                            value: status.toUpperCase(),
                            icon: Icons.verified_user_outlined,
                            isStatus: true,
                            isDark: isDark,
                            textColor: themeProvider.textColor,
                          ),
                          _buildModernCard(
                            label: 'Guru Pengabsen',
                            value: guruName,
                            icon: Icons.edit_note_rounded,
                            isLast: imageUrl == null,
                            isDark: isDark,
                            textColor: themeProvider.textColor,
                          ),
                          if (imageUrl != null) ...[
                            const SizedBox(height: 20),
                            _sectionTitle('BUKTI LAMPIRAN', isDark),
                            Container(
                              width: double.infinity,
                              height: 200,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                                image: DecorationImage(
                                  image: NetworkImage(ApiService.baseUrl.replaceAll('/api', '/storage/') + imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 35),
                          
                          // Action Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                              label: const Text(
                                'KONFIRMASI SELESAI',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  letterSpacing: 1.2,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: isDark ? 0 : 6,
                                shadowColor: primaryOrange.withOpacity(0.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.grey.shade400,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    required Color textColor,
    bool isStatus = false,
    bool isLast = false,
  }) {
    Color getStatusColor() {
      if (!isStatus) return textColor;
      if (value.contains('HADIR')) return Colors.green.shade400;
      if (value.contains('ALFA')) return Colors.red.shade400;
      return primaryOrange;
    }

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade50),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isStatus 
                ? getStatusColor().withOpacity(0.1) 
                : (isDark ? Colors.white.withOpacity(0.05) : lightOrangeBg.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isStatus ? getStatusColor() : primaryOrange, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey.shade500, 
                    fontSize: 10, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}