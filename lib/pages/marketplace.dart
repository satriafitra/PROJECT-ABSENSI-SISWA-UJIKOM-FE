import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/session.dart';
import '../providers/theme_provider.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  static const Color primaryOrange = Color(0xFFFF6B35);
  String selectedCategory = "Semua";

  // Simulasi data produk (Nantinya ganti dengan data dari API CRUD Laravel kamu)
  final List<Map<String, dynamic>> products = [
    {
      "name": "Buku Note Akva",
      "price": 50,
      "image": "https://via.placeholder.com/150",
      "category": "Alat Tulis"
    },
    {
      "name": "Pena Premium",
      "price": 20,
      "image": "https://via.placeholder.com/150",
      "category": "Alat Tulis"
    },
    {
      "name": "Kaos Kaki Sekolah",
      "price": 35,
      "image": "https://via.placeholder.com/150",
      "category": "Pakaian"
    },
    {
      "name": "Gantungan Kunci QR",
      "price": 15,
      "image": "https://via.placeholder.com/150",
      "category": "Aksesoris"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Filter produk berdasarkan kategori yang dipilih
    final filteredProducts = selectedCategory == "Semua"
        ? products
        : products.where((p) => p['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: themeProvider.textColor, size: 20),
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
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: themeProvider.textColor),
            onPressed: () {
              // Navigasi ke riwayat penukaran poin jika ada
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BAGIAN SALDO POIN (Sinkron dengan App Header)
          _buildBalanceCard(isDark),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Text(
              "Kategori",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // 2. LIST KATEGORI
          _buildCategoryList(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: Text(
              "Produk Spesial Untukmu",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // 3. GRID PRODUK
          Expanded(
            child: filteredProducts.isEmpty 
              ? const Center(child: Text("Produk tidak tersedia"))
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(filteredProducts[index], isDark, themeProvider);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    // MENGAMBIL POIN DARI SESSION (Sama dengan App Header)
    final int myPoints = Session.studentPoints ?? 0;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryOrange, Color(0xFFFF9F67)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Poin Aktif",
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    myPoints.toString(),
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 32, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Hiasan koin transparan agar mewah
          Icon(Icons.account_balance_wallet_outlined, 
               color: Colors.white.withOpacity(0.2), 
               size: 60),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    List<String> categories = ["Semua", "Alat Tulis", "Pakaian", "Aksesoris"];
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? primaryOrange : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: isSelected 
                    ? null 
                    : Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isDark, ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                image: DecorationImage(
                  image: NetworkImage(product['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  product['category'],
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: primaryOrange, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "${product['price']}",
                          style: const TextStyle(
                            color: primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    // Tombol Tambah/Beli
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: primaryOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_basket_outlined, color: Colors.white, size: 16),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
