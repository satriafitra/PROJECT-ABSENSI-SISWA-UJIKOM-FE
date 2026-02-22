import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../utils/session.dart';
import '../pages/login_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // --- Orange Elegance Palette ---
  static const Color primaryOrange =
      Color(0xFFFF6B35); // Warna utama (Strong Orange)
  static const Color lightOrange = Color(0xFFFFF4F0); // Background menu aktif
  static const Color accentOrange = Color(0xFFFF9F67); // Gradasi soft
  static const Color darkGrey = Color(0xFF454545);

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
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header dengan Gradasi Orange Modern
          _buildHeader(context),

          const SizedBox(height: 15),

          // Menu Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_customize_rounded,
                  title: "Beranda",
                  isSelected: true, // Menandakan sedang di halaman ini
                  onTap: () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.assignment_turned_in_rounded,
                  title: "Riwayat Absensi",
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  // Menggunakan Icons.explore_rounded untuk kesan yang lebih modern dan dinamis
                  icon: Icons.location_on_rounded,
                  title: "Area Absensi",
                  onTap: () {
                    // Navigasi ke halaman map absensi di sini
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_suggest_rounded,
                  title: "Pengaturan",
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Divider halus sebelum logout
          Divider(
              color: Colors.grey.withOpacity(0.1),
              thickness: 1,
              indent: 20,
              endIndent: 20),

          // Logout Button
          _buildLogoutButton(context),
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
          // Profile Picture Ring
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
          // User Info
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
              Icon(Icons.badge_outlined,
                  size: 14, color: Colors.white.withOpacity(0.8)),
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
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        selected: isSelected,
        selectedTileColor: lightOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        leading: Icon(
          icon,
          color: isSelected ? primaryOrange : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryOrange : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
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
              border: Border.all(color: Colors.red.withOpacity(0.2)),
              color: Colors.red.withOpacity(0.05),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.power_settings_new_rounded,
                    color: Colors.redAccent, size: 20),
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
