import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Wajib ditambahkan
import '../providers/theme_provider.dart'; // Sesuaikan path provider Anda
import 'home_absensi.dart';
import 'qr_scanner_page.dart';
import 'kalender.dart';
import '../widgets/app_header.dart';
import '../widgets/app_drawer.dart';

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

  void _onItemTapped(int i) {
    HapticFeedback.selectionClick();
    setState(() => index = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Memanggil provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      // Menggunakan warna background dari provider
      backgroundColor: themeProvider.bgWhite,
      extendBody: true,
      endDrawer: const AppDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              const AppHeader(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => index = i),
                  children: pages,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _qrButton(themeProvider), // Kirim provider ke widget
      bottomNavigationBar: _buildEnhancedNav(themeProvider), // Kirim provider ke widget
    );
  }

  // ================= ENHANCED BOTTOM NAV (DYNAMIZED) =================
  Widget _buildEnhancedNav(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(themeProvider.isDarkMode ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        child: BottomAppBar(
          padding: EdgeInsets.zero,
          elevation: 0,
          notchMargin: 12,
          // Menggunakan warna card dari provider (Putih atau Abu Gelap)
          color: themeProvider.cardColor, 
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  themeProvider, // Kirim provider
                  label: "Home",
                  icon: Icons.grid_view_rounded,
                  isActive: index == 0,
                  onTap: () => _onItemTapped(0),
                ),
                const SizedBox(width: 60),
                _navItem(
                  themeProvider, // Kirim provider
                  label: "History",
                  icon: Icons.event_note_rounded,
                  isActive: index == 1,
                  onTap: () => _onItemTapped(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    ThemeProvider themeProvider, {
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // Jika aktif, gunakan orange soft, jika gelap buat lebih transparan agar elegan
                color: isActive 
                    ? (themeProvider.isDarkMode ? Colors.orange.withOpacity(0.15) : const Color(0xFFFFE5D9).withOpacity(0.5))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 26,
                // Gunakan orange deep jika aktif, gunakan grey terang jika gelap & tidak aktif
                color: isActive ? const Color(0xFFFE6F47) : (themeProvider.isDarkMode ? Colors.grey[600] : Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 15 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFFE6F47),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= QR BUTTON (DYNAMIZED) =================
  Widget _qrButton(ThemeProvider themeProvider) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Wadah luar mengikuti warna card agar "lubang" notch tidak terlihat aneh
        color: themeProvider.cardColor, 
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFE6F47).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.transparent,
        onPressed: () {
          HapticFeedback.heavyImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QrScanPage()),
          );
        },
        shape: const CircleBorder(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8E62), Color(0xFFFE6F47), Color(0xFFE65100)],
            ),
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}