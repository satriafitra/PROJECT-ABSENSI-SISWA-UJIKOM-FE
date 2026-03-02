import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Wajib import
import '../providers/theme_provider.dart'; // Sesuaikan path file provider kamu

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Memanggil provider untuk mendengarkan perubahan tema
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      // Mengambil background dinamis (Gelap/Terang)
      backgroundColor: themeProvider.bgWhite,
      appBar: AppBar(
        title: Text(
          "Pengaturan",
          style: TextStyle(
            color: themeProvider.textColor, 
            fontWeight: FontWeight.bold
          ),
        ),
        // Background AppBar juga mengikuti tema
        backgroundColor: themeProvider.cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: themeProvider.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tampilan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeProvider.subTextColor,
              ),
            ),
            const SizedBox(height: 15),
            
            // Card Mode Gelap yang sudah AKTIF
            Container(
              decoration: BoxDecoration(
                color: themeProvider.cardColor, // Dinamis
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? Colors.blueGrey[900] : const Color(0xFFFFE5D9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: themeProvider.isDarkMode ? Colors.yellow : const Color(0xFFFE6F47),
                  ),
                ),
                title: Text(
                  "Mode Gelap",
                  style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    fontSize: 16,
                    color: themeProvider.textColor // Teks jadi putih saat gelap
                  ),
                ),
                subtitle: Text(
                  themeProvider.isDarkMode ? "Aktif" : "Nonaktif",
                  style: TextStyle(color: themeProvider.subTextColor),
                ),
                trailing: Switch.adaptive(
                  activeColor: const Color(0xFFFE6F47),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    HapticFeedback.mediumImpact();
                    // MEMANGGIL LOGIKA TOGGLE THEME
                    themeProvider.toggleTheme(value);
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),
            Text(
              "Lainnya",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeProvider.subTextColor,
              ),
            ),
            const SizedBox(height: 15),

            _buildSettingsItem(
              context,
              icon: Icons.notifications_active_rounded,
              title: "Notifikasi",
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              icon: Icons.security_rounded,
              title: "Keamanan Akun",
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              context,
              icon: Icons.info_outline_rounded,
              title: "Tentang Aplikasi",
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper yang disesuaikan dengan tema
  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor, // Dinamis
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 16,
            color: themeProvider.textColor // Dinamis
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: themeProvider.subTextColor),
        onTap: () {},
      ),
    );
  }
}