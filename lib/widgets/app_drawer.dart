import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../utils/session.dart';
import '../pages/login_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Color Palette - Blue Theme
  static const Color primaryBlue = Color(0xFF1E3A8A); // Deep Navy
  static const Color accentBlue = Color(0xFF3B82F6);  // Bright Blue
  static const Color lightBlue = Color(0xFFEFF6FF);   // Background Blue

  void _handleLogout(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: 'Apakah kamu yakin ingin keluar?',
      confirmBtnText: 'Ya, Keluar',
      cancelBtnText: 'Batal',
      confirmBtnColor: Colors.redAccent,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Elegant Header
          _buildHeader(context),

          const SizedBox(height: 12),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildMenuItem(
                  icon: Icons.home_rounded,
                  title: "Beranda",
                  onTap: () => Navigator.pop(context),
                  isSelected: true, // Highlight item aktif
                ),
                _buildMenuItem(
                  icon: Icons.history_rounded,
                  title: "Riwayat Absen",
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.settings_rounded,
                  title: "Pengaturan",
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: "Tentang Aplikasi",
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Logout Button at Bottom
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, accentBlue],
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: primaryBlue),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            Session.studentName ?? 'Siswa Terpelajar',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              Session.nisn ?? 'NISN: 00000000',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? lightBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Icon(
          icon,
          color: isSelected ? primaryBlue : Colors.grey[600],
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryBlue : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () => _handleLogout(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.1)),
          ),
          child: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
              SizedBox(width: 15),
              Text(
                "Keluar Akun",
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
    );
  }
}