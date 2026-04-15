import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/session.dart';
import '../providers/theme_provider.dart';
import '../services/api_services.dart';

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

  IconData getIcon(String icon) {
    switch (icon) {
      case 'gift': return Icons.redeem_rounded;
      case 'log-out': return Icons.exit_to_app_rounded;
      case 'bolt': return Icons.bolt_rounded;
      default: return Icons.confirmation_number_rounded;
    }
  }

  // ================= HANDLE BUY (BOTTOM SHEET) =================
  Future<void> handleBuy(Map<String, dynamic> product) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final int myPoints = themeProvider.studentPoints;
    final int price = product['price'];

    if (myPoints < price) {
      _showCustomSnackBar("Poin kamu kurang ${price - myPoints} poin lagi! 😥", Colors.redAccent);
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
      _showCustomSnackBar("Berhasil tukar ${product['name']}! 🎉", Colors.green);
      setState(() {});
    } else {
      _showCustomSnackBar(result['message'] ?? "Gagal menukar poin", Colors.red);
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
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFBFBFD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: themeProvider.textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Siswa Shop",
          style: TextStyle(color: themeProvider.textColor, fontWeight: FontWeight.w900, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumBalanceCard(themeProvider),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text("Kategori", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          _buildCategoryList(),

          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Text("Voucher Untukmu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryOrange))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(filteredProducts[index], themeProvider);
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
            // Ornamen Dekoratif (Lingkaran)
            Positioned(
              top: -30,
              right: -30,
              child: CircleAvatar(radius: 70, backgroundColor: Colors.white.withOpacity(0.1)),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              child: CircleAvatar(radius: 50, backgroundColor: Colors.white.withOpacity(0.06)),
            ),
            
            // Konten Saldo
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "SALDO POIN KAMU",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "${themeProvider.studentPoints}",
                            style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "PTS",
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Icon Wallet dengan Glassmorphism
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32),
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
                boxShadow: isSelected ? [BoxShadow(color: primaryOrange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                border: isSelected ? null : Border.all(color: Colors.grey.shade200),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= WIDGET: PRODUCT CARD =================
  Widget _buildProductCard(Map<String, dynamic> product, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => handleBuy(product),
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(child: Icon(getIcon(product['icon']), size: 45, color: primaryOrange)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars_rounded, size: 16, color: primaryOrange),
                          const SizedBox(width: 4),
                          Text("${product['price']}", style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.w900, fontSize: 15)),
                        ],
                      ),
                      const Icon(Icons.add_circle_rounded, color: primaryOrange, size: 22),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= WIDGET: BOTTOM SHEET KONFIRMASI =================
  Widget _buildConfirmBottomSheet(Map<String, dynamic> product, int price, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),
          const Text("Tukar Poin?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 40,
            backgroundColor: primaryOrange.withOpacity(0.1),
            child: Icon(getIcon(product['icon']), color: primaryOrange, size: 40),
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
                  child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Ya, Tukar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}