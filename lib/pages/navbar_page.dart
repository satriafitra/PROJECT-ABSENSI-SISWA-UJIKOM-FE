import 'package:flutter/material.dart';
import 'home_absensi.dart';
import 'qr_scanner_page.dart';
import 'kalender.dart';
import '../widgets/app_header.dart';

const orangeMain = Color.fromARGB(255, 254, 111, 71);
const orangeSoft = Color(0xFFFFC09A);
const yellowQR = Color(0xFFFFC107);

class NavbarPage extends StatefulWidget {
  const NavbarPage({super.key});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  int index = 0;
  final PageController _pageController = PageController();

  final pages = const [
    HomePage(),
    KalenderPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ================= HEADER GLOBAL =================
      body: Column(
        children: [
          const AppHeader(), // 🔥 Hanya 1 kali di Navbar
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) {
                setState(() => index = i);
              },
              children: pages,
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _qrButton(),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ================= BOTTOM NAV (TIDAK DIUBAH) =================
  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            offset: Offset(0, -6),
            color: Colors.black12,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(42),
          topRight: Radius.circular(42),
        ),
        child: BottomAppBar(
          color: orangeMain,
          shape: const CircularNotchedRectangle(),
          notchMargin: 16,
          child: SizedBox(
            height: 86,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navIcon(
                    icon: Icons.dashboard_rounded,
                    isActive: index == 0,
                    onTap: () {
                      setState(() => index = 0);
                      _pageController.jumpToPage(0);
                    },
                  ),
                  const SizedBox(width: 72),
                  _navIcon(
                    icon: Icons.event_available_rounded,
                    isActive: index == 1,
                    onTap: () {
                      setState(() => index = 1);
                      _pageController.jumpToPage(1);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navIcon({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: orangeSoft.withOpacity(0.9),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: AnimatedScale(
          scale: isActive ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Icon(
            icon,
            size: 34,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

// ================= QR BUTTON (LARGE & SPACIOUS) =================
  Widget _qrButton() {
    return Container(
      // Container luar sebagai pembatas putih
      width: 82,
      height: 82,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white, // Memberikan ring putih di luar lingkaran orange
      ),
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor:
            Colors.transparent, // Agar background putih di atas yang terlihat
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QrScanPage()),
          );
        },
        shape: const CircleBorder(),
        child: Container(
          // DISINI PERUBAHANNYA: Ukuran diperbesar secara signifikan
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 240, 72, 26),
                Color(0xFFFF8E62), // Warna orange yang sedikit lebih terang
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: orangeMain.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          // Gunakan Center agar icon tetap presisi di tengah container besar
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            // Icon tetap di ukuran medium agar terlihat elegan dalam container besar
            size: 37,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
