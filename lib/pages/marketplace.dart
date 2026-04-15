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

    setState(() {
      products = data;
      isLoading = false;
    });
  }

  // ================= ICON =================
  IconData getIcon(String icon) {
    switch (icon) {
      case 'gift':
        return Icons.card_giftcard;
      case 'log-out':
        return Icons.logout;
      case 'bolt':
        return Icons.flash_on;
      default:
        return Icons.confirmation_num;
    }
  }

  // ================= HANDLE BELI (FIX UTAMA) =================
  Future<void> handleBuy(Map<String, dynamic> product) async {
    final themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);

    final int myPoints = themeProvider.studentPoints; // 🔥 dari provider
    final int price = product['price'];

    // ❌ VALIDASI
    if (myPoints < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Poin tidak cukup"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ KONFIRMASI
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text("Tukar ${product['name']} dengan $price poin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Beli"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 🔥 HIT API
    final result = await ApiService.redeemItem(
      studentId: Session.id!,
      itemId: product['id'],
    );

    if (result['success'] == true) {
      int newPoints = result['points'];

      // ✅ UPDATE SESSION
      await Session.updatePoints(newPoints);

      // ✅ UPDATE PROVIDER (INI YANG BIKIN HEADER LANGSUNG BERUBAH)
      themeProvider.updatePoints(newPoints);

      // 🔥 REFRESH UI MARKETPLACE
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Gagal"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final filteredProducts = selectedCategory == "Semua"
        ? products
        : products
            .where((p) => p['category'] == selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: themeProvider.textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Siswa Shop",
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceCard(themeProvider),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Text(
              "Kategori",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          _buildCategoryList(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: Text(
              "Voucher Untukmu",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? const Center(child: Text("Produk tidak tersedia"))
                    : GridView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
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

  // 🔥 PAKAI PROVIDER (BUKAN SESSION)
  Widget _buildBalanceCard(ThemeProvider themeProvider) {
    final int myPoints = themeProvider.studentPoints;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryOrange, Color(0xFFFF9F67)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Poin",
                  style:
                      TextStyle(color: Colors.white.withOpacity(0.9))),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.stars, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    "$myPoints",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.wallet, color: Colors.white54, size: 50)
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    List<String> categories = ["Semua", "Reward", "Izin", "Fasilitas"];

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == categories[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = categories[index];
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color:
                    isSelected ? primaryOrange : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
      Map<String, dynamic> product, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => handleBuy(product),
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Icon(
                    getIcon(product['icon']),
                    size: 50,
                    color: primaryOrange,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(product['category'],
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars,
                              size: 14, color: primaryOrange),
                          const SizedBox(width: 4),
                          Text(
                            "${product['price']}",
                            style: const TextStyle(
                                color: primaryOrange,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Icon(Icons.shopping_basket,
                          color: primaryOrange)
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
}