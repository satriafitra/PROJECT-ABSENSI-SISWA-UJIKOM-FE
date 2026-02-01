import 'package:flutter/material.dart';
import 'home_absensi.dart';

const orangeMain = Color.fromARGB(255, 254, 111, 71);
const orangeSoft = Color(0xFFFFC09A);

class NavbarPage extends StatefulWidget {
  const NavbarPage({super.key});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  int index = 0;

  final pages = const [
    HomePage(),
    HomePage(), // dummy jadwal
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _qrButton(),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ================= BOTTOM NAV =================
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
                    onTap: () => setState(() => index = 0),
                  ),
                  const SizedBox(width: 72),
                  _navIcon(
                    icon: Icons.event_available_rounded,
                    isActive: index == 1,
                    onTap: () => setState(() => index = 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= NAV ICON (GLOW ANIMATE) =================
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

  // ================= QR BUTTON =================
  Widget _qrButton() {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            color: orangeMain.withOpacity(.45),
          )
        ],
      ),
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.white,
        onPressed: () {},
        shape: const CircleBorder(),
        child: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: orangeMain,
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            size: 34,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
