import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Wajib ditambahkan
import 'package:quickalert/quickalert.dart';
import '../utils/session.dart';
import '../pages/login_page.dart';
import '../pages/area_gps.dart';
import '../pages/pengaturan.dart';
import '../pages/riwayat_absensi.dart'; // Sesuaikan path riwayat absensi Anda
import '../providers/theme_provider.dart'; // Sesuaikan path provider Anda

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // --- Orange Palette ---
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color accentOrange = Color(0xFFFF9F67);

  void _handleLogout(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: 'Apakah kamu yakin ingin keluar?',
      confirmBtnText: 'Ya, Keluar',
      cancelBtnText: 'Batal',
      confirmBtnColor: primaryOrange,
      onConfirmBtnTap: () async {
        await Session.logout();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil state tema
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      backgroundColor: themeProvider.cardColor, // Menggunakan warna kartu (putih/abu gelap)
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header tetap menggunakan gradasi orange agar konsisten
          _buildHeader(context),

          const SizedBox(height: 15),

          // Menu Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildMenuItem(
                  context,
                  themeProvider: themeProvider,
                  icon: Icons.dashboard_customize_rounded,
                  title: "Beranda",
                  isSelected: true,
                  onTap: () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  context,
                  themeProvider: themeProvider,
                  icon: Icons.assignment_turned_in_rounded,
                  title: "Riwayat Absensi",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RiwayatAbsensiPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  themeProvider: themeProvider,
                  icon: Icons.location_on_rounded,
                  title: "Area Absensi",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AreaGpsPage()),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  themeProvider: themeProvider,
                  icon: Icons.settings_suggest_rounded,
                  title: "Pengaturan",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          Divider(
            color: themeProvider.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),

          // Logout Button
          _buildLogoutButton(context, themeProvider),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryOrange, accentOrange],
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white30,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, size: 45, color: primaryOrange),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            Session.studentName ?? 'Siswa Aktif',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.badge_outlined, size: 14, color: Colors.white.withOpacity(0.8)),
              const SizedBox(width: 5),
              Text(
                Session.nisn ?? 'NISN Tidak Tersedia',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required ThemeProvider themeProvider, // Tambahkan parameter provider
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    // Warna background menu saat aktif (di Dark Mode dibuat lebih redup)
    final Color selectedBg = themeProvider.isDarkMode 
        ? primaryOrange.withOpacity(0.15) 
        : const Color(0xFFFFF4F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        selected: isSelected,
        selectedTileColor: selectedBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        leading: Icon(
          icon,
          color: isSelected ? primaryOrange : themeProvider.subTextColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryOrange : themeProvider.textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleLogout(context),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: themeProvider.isDarkMode ? Colors.redAccent.withOpacity(0.3) : Colors.red.withOpacity(0.2),
              ),
              color: Colors.red.withOpacity(0.05),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.power_settings_new_rounded, color: Colors.redAccent, size: 20),
                SizedBox(width: 10),
                Text(
                  "Keluar Aplikasi",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}