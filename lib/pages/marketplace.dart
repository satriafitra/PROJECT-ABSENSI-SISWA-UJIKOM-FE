import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/session.dart';
import '../providers/theme_provider.dart';
import '../services/api_services.dart';
import 'package:absensi_app/pages/inventory.dart';

// ================= HELPER: TICKET CLIPPER =================
// Digunakan untuk membuat lubang tiket yang benar-benar terpotong (transparan)
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    // Lubang Lingkaran Atas (posisi horizontal 45)
    path.addOval(Rect.fromCircle(center: Offset(45, 0), radius: 10));
    // Lubang Lingkaran Bawah (posisi horizontal 45)
    path.addOval(Rect.fromCircle(center: Offset(45, size.height), radius: 10));

    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ================= HELPER: DASHED LINE PAINTER =================
class DashLinePainter extends CustomPainter {
  final Color color;
  DashLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 15;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    while (startY < size.height - 15) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color accentOrange = Color(0xFFFF9F67);

  String selectedCategory = "Semua";
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final data = await ApiService.fetchMarketplace();
    if (mounted) {
      setState(() {
        products = data;
        isLoading = false;
      });
    }
  }

  // ================= HANDLE BUY (TETAP SAMA) =================
  Future<void> handleBuy(Map<String, dynamic> product) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final int myPoints = themeProvider.studentPoints;
    final int price = product['price'];

    if (myPoints < price) {
      _showCustomSnackBar("Poin kamu kurang ${price - myPoints} poin lagi! 😥",
          Colors.redAccent);
      return;
    }

    final bool? confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          _buildConfirmBottomSheet(product, price, themeProvider),
    );

    if (confirm != true) return;

    final result = await ApiService.redeemItem(
      studentId: Session.id!,
      itemId: product['id'],
    );

    if (result['success'] == true) {
      int newPoints = result['points'];
      await Session.updatePoints(newPoints);
      themeProvider.updatePoints(newPoints);
      _showCustomSnackBar(
          "Berhasil tukar ${product['name']}! 🎉", Colors.green);
      setState(() {});
    } else {
      _showCustomSnackBar(
          result['message'] ?? "Gagal menukar poin", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final filteredProducts = selectedCategory == "Semua"
        ? products
        : products.where((p) => p['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFFBFBFD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: themeProvider.textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Siswa Shop",
          style: TextStyle(
              color: themeProvider.textColor,
              fontWeight: FontWeight.w900,
              fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryPage()),
              );
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumBalanceCard(themeProvider),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text("Kategori",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildCategoryList(),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Text("Voucher Untukmu",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryOrange))
                : ListView.builder(
                    // Menggunakan ListView agar card lebar terlihat elegan
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(
                          filteredProducts[index], themeProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= WIDGET: PREMIUM BALANCE CARD =================
  Widget _buildPremiumBalanceCard(ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      height: 140,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [primaryOrange, Color(0xFFFB8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.35),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: CircleAvatar(
                  radius: 70, backgroundColor: Colors.white.withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "SALDO POIN KAMU",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "${themeProvider.studentPoints}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "PTS",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET: CATEGORY LIST =================
  Widget _buildCategoryList() {
    List<String> categories = ["Semua", "Reward", "Izin", "Fasilitas"];
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == categories[index];
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = categories[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected ? primaryOrange : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: primaryOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ]
                    : [],
                border:
                    isSelected ? null : Border.all(color: Colors.grey.shade200),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= WIDGET: PREMIUM PRODUCT CARD (VOUCHER DESIGN) =================
  Widget _buildProductCard(
      Map<String, dynamic> product, ThemeProvider themeProvider) {
    Color getPrimaryColor() {
      switch (product['theme']) {
        case 'izin':
          // Warna Terra Cotta/Soft Red yang harmonis dengan oranye
          return const Color(0xFFE67E22).withRed(220);
        case 'fasilitas':
          // Warna Biru Laut yang modern (Slate Blue)
          return const Color(0xFF45AAF2);
        default:
          // Oranye Branding Utama (Golden Orange)
          return const Color(0xFFFA8231);
      }
    }

    // Warna gradasi untuk kedalaman visual
    Color getSecondaryColor() {
      switch (product['theme']) {
        case 'izin':
          return const Color(0xFFEB3B5A); // Lebih ke arah pinkish-red agar soft
        case 'fasilitas':
          return const Color(0xFF2D98DA);
        default:
          return const Color(0xFFF7B731);
      }
    }

    return GestureDetector(
      onTap: () => handleBuy(product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Stack(
          children: [
            // Bayangan yang lebih halus (Glow Effect)
            Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: getPrimaryColor().withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
            ),

            ClipPath(
              clipper: TicketClipper(),
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      getPrimaryColor(),
                      getSecondaryColor(),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    // SISI KIRI: LABEL KATEGORI
                    Container(
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(20)),
                      ),
                      child: Center(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            product['category'].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // PEMISAH: GARIS PUTUS-PUTUS (DASHED)
                    CustomPaint(
                      size: const Size(1, double.infinity),
                      painter: DashLinePainter(Colors.white.withOpacity(0.5)),
                    ),

                    // ISI VOUCHER
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product['description'] ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            // Badge Harga yang lebih kontras (Glassmorphism style)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Text(
                                "${product['price']} PTS",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ICON PEMANIS (Opacity ditingkatkan sedikit)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        _getIconByTheme(product['theme']),
                        color: Colors.white.withOpacity(0.25),
                        size: 44,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper untuk icon agar iconnya juga beda tiap tema
  IconData _getIconByTheme(String theme) {
    switch (theme) {
      case 'izin':
        return Icons.event_available_rounded;
      case 'fasilitas':
        return Icons.home_repair_service_rounded;
      default:
        return Icons.stars_rounded;
    }
  }

  // ================= WIDGET: BOTTOM SHEET KONFIRMASI =================
  Widget _buildConfirmBottomSheet(
      Map<String, dynamic> product, int price, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),
          const Text("Tukar Poin?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 40,
            backgroundColor: primaryOrange.withOpacity(0.1),
            child: const Icon(Icons.confirmation_number_rounded,
                color: primaryOrange, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            "Kamu akan menukar ${product['name']} seharga $price poin. Lanjutkan?",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Batal",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Ya, Tukar",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showCustomSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
