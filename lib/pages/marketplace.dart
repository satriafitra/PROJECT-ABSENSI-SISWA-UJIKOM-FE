import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../utils/session.dart';
import '../providers/theme_provider.dart';
import '../services/api_services.dart';

// ================= HELPER: TICKET CLIPPER =================
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    path.addOval(Rect.fromCircle(center: const Offset(45, 0), radius: 10));
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
    double dashHeight = 5, dashSpace = 4, startY = 15;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
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

class _MarketplacePageState extends State<MarketplacePage> with SingleTickerProviderStateMixin {
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

  // ================= HANDLE BUY =================
  Future<void> handleBuy(Map<String, dynamic> product) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final int myPoints = themeProvider.studentPoints;
    final int price = product['price'];

    if (myPoints < price) {
      _showAnimatedAlert(
        title: "Poin Tidak Cukup!",
        message: "Poin kamu kurang ${price - myPoints} poin lagi untuk menukarkan item ini. Semangat kumpulkan poin lagi ya! 😥",
        isSuccess: false,
      );
      return;
    }

    final bool? confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildConfirmBottomSheet(product, price, themeProvider),
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
      _showAnimatedAlert(
        title: "Penukaran Berhasil! 🎉",
        message: "Kamu telah sukses menukarkan poinmu dengan ${product['name']}. Cek menu inventory kamu sekarang!",
        isSuccess: true,
      );
      setState(() {});
    } else {
      _showAnimatedAlert(
        title: "Penukaran Gagal",
        message: result['message'] ?? "Terjadi kesalahan saat menukar poin. Silakan coba lagi nanti.",
        isSuccess: false,
      );
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
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // --- Background Blur Elements ---
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryOrange.withOpacity(isDark ? 0.15 : 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5F27CD).withOpacity(isDark ? 0.15 : 0.05),
              ),
            ),
          ),
          // Blur Layer over background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: const SizedBox(),
            ),
          ),

          // --- Main Content ---
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomAppBar(themeProvider, isDark),
                _buildPremiumBalanceCard(themeProvider),
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Text(
                    "Kategori Pilihan",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _buildCategoryList(isDark),
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Text(
                    "Voucher Untukmu",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: primaryOrange))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 400)),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 50 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildProductCard(filteredProducts[index], themeProvider, isDark),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= WIDGET: CUSTOM APP BAR =================
  Widget _buildCustomAppBar(ThemeProvider themeProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: themeProvider.textColor, size: 20),
            ),
          ),
          Text(
            "Siswa Shop",
            style: TextStyle(
              color: themeProvider.textColor,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 46), // To balance the back button
        ],
      ),
    );
  }

  // ================= WIDGET: PREMIUM BALANCE CARD =================
  Widget _buildPremiumBalanceCard(ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6B35),
            Color(0xFFFF9F67),
            Color(0xFFF9A826),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background decorative circles
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -60,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "SALDO POIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${themeProvider.studentPoints}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          "PTS",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.wallet_giftcard_rounded,
                  color: Color(0xFFFF6B35),
                  size: 36,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= WIDGET: CATEGORY LIST =================
  Widget _buildCategoryList(bool isDark) {
    List<Map<String, dynamic>> categories = [
      {"name": "Semua", "icon": Icons.grid_view_rounded},
      {"name": "Reward", "icon": Icons.card_giftcard_rounded},
      {"name": "Izin", "icon": Icons.event_available_rounded},
      {"name": "Fasilitas", "icon": Icons.chair_alt_rounded},
    ];
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String name = categories[index]['name'];
          IconData icon = categories[index]['icon'];
          bool isSelected = selectedCategory == name;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF9F67)])
                    : null,
                color: isSelected ? null : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                borderRadius: BorderRadius.circular(26),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: const Color(0xFFFF6B35).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6))
                      ]
                    : [
                        if (!isDark)
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                      ],
                border: isSelected
                    ? null
                    : Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= WIDGET: PREMIUM PRODUCT CARD =================
  Widget _buildProductCard(Map<String, dynamic> product, ThemeProvider themeProvider, bool isDark) {
    Color getPrimaryColor() {
      switch (product['theme']) {
        case 'izin': return const Color(0xFFEF4444); // Red
        case 'fasilitas': return const Color(0xFF06B6D4); // Cyan
        case 'voucher': return const Color(0xFF8B5CF6); // Violet
        default: return const Color(0xFFF59E0B); // Amber
      }
    }

    Color getSecondaryColor() {
      switch (product['theme']) {
        case 'izin': return const Color(0xFFF87171);
        case 'fasilitas': return const Color(0xFF22D3EE);
        case 'voucher': return const Color(0xFFA78BFA);
        default: return const Color(0xFFFBBF24);
      }
    }

    return GestureDetector(
      onTap: () => handleBuy(product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Stack(
          children: [
            // Outer glow / shadow
            Container(
              height: 125,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: getPrimaryColor().withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
            ),
            ClipPath(
              clipper: TicketClipper(),
              child: Container(
                height: 125,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [getPrimaryColor(), getSecondaryColor()],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background watermarked icon
                    Positioned(
                      right: -15,
                      bottom: -20,
                      child: Icon(
                        _getIconByTheme(product['theme']),
                        size: 110,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    Row(
                      children: [
                        // Left vertical category label
                        Container(
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                          ),
                          child: Center(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                product['category'].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Dashed line
                        CustomPaint(
                          size: const Size(1, double.infinity),
                          painter: DashLinePainter(Colors.white.withOpacity(0.6)),
                        ),
                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Text(
                                    product['description'] ?? '',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${product['price']} PTS",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: getPrimaryColor(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconByTheme(String theme) {
    switch (theme) {
      case 'izin': return Icons.event_available_rounded;
      case 'fasilitas': return Icons.home_repair_service_rounded;
      case 'voucher': return Icons.local_activity_rounded;
      default: return Icons.stars_rounded;
    }
  }

  // ================= WIDGET: BOTTOM SHEET KONFIRMASI =================
  Widget _buildConfirmBottomSheet(Map<String, dynamic> product, int price, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10)
            )
          ),
          const SizedBox(height: 28),
          Text(
            "Tukar Poin?",
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w900,
              color: themeProvider.textColor
            )
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_rounded, color: primaryOrange, size: 48),
          ),
          const SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 16,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: "Kamu akan menukar "),
                TextSpan(
                  text: "${product['name']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: primaryOrange),
                ),
                const TextSpan(text: " seharga "),
                TextSpan(
                  text: "$price poin",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ". Lanjutkan?"),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    "Batal",
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600, 
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: primaryOrange.withOpacity(0.4),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Ya, Tukar",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showAnimatedAlert({required String title, required String message, required bool isSuccess}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            elevation: 0,
            content: Container(
              width: 340,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: (isSuccess ? Colors.green : Colors.redAccent).withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: (isSuccess ? Colors.green : Colors.redAccent).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: isSuccess ? Colors.green : Colors.redAccent,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: (isSuccess ? Colors.green : Colors.redAccent).withOpacity(0.4),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Oke, Mengerti",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
