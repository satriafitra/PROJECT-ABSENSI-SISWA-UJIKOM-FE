import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_services.dart';
import '../utils/session.dart';
import '../providers/theme_provider.dart';
import '../widgets/ticket_clipper.dart'; // Import reusable widget

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<dynamic> vouchers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final data = await ApiService.fetchMyVouchers(Session.id!);
      if (mounted) {
        setState(() {
          vouchers = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          vouchers = [];
          isLoading = false;
        });
      }
    }
  }

  Future<void> _useVoucher(int voucherId) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFE6F47)),
      ),
    );

    try {
      final res = await ApiService.useVoucher(voucherId: voucherId);
      Navigator.pop(context); // Close loading dialog

      if (res['success'] == true) {
        _showSnackBar("Voucher berhasil diaktifkan 🎉", Colors.green);
        fetchData();
      } else {
        _showSnackBar(res['message'] ?? "Gagal menggunakan voucher", Colors.redAccent);
      }
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar("Terjadi kesalahan koneksi", Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.bgWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: themeProvider.textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Voucher Saya",
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFE6F47),
        onRefresh: fetchData,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Koleksi Voucher",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFE6F47)))
                  : vouchers.isEmpty
                      ? _buildEmptyState(themeProvider)
                      : _buildListView(themeProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(ThemeProvider themeProvider) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        return _buildPremiumVoucherCard(vouchers[index], themeProvider);
      },
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFE6F47).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 80,
                color: Color(0xFFFE6F47),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Belum ada voucher tersedia",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Yuk, kumpulkan poin dan tukarkan\ndi Siswa Shop!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeProvider.subTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumVoucherCard(Map<String, dynamic> v, ThemeProvider themeProvider) {
    final String status = (v['status'] ?? 'AVAILABLE').toString();
    final bool isUsed = v['attendance_id'] != null;
    final bool isActive = status == 'ACTIVE';
    final bool isAvailable = status == 'AVAILABLE';

    // UI Configuration based on status
    Color primaryColor = const Color(0xFFFE6F47);
    Color secondaryColor = const Color(0xFFFF9F67);
    String statusText = "SIAP DIGUNAKAN";
    IconData iconData = Icons.local_activity_rounded;

    if (isUsed) {
      primaryColor = const Color(0xFF757575); // Grey
      secondaryColor = const Color(0xFFBDBDBD);
      statusText = "SUDAH TERPAKAI";
      iconData = Icons.check_circle_rounded;
    } else if (isActive) {
      primaryColor = const Color(0xFF00D2D3); // Teal/Cyan
      secondaryColor = const Color(0xFF48DBFB);
      statusText = "SEDANG AKTIF";
      iconData = Icons.timer_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // Glowing Shadow Effect
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
          ),

          ClipPath(
            clipper: TicketClipper(),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // SISI KIRI: ICON STATUS
                  Container(
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                    ),
                    child: Center(
                      child: Icon(iconData, color: Colors.white.withOpacity(0.8), size: 24),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            v['name'] ?? 'Voucher',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            v['description'] ?? '-',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          // Badge Status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(
                              statusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // SISI KANAN: ACTION BUTTON / STATUS ICON LENGKAP
                  Container(
                    padding: const EdgeInsets.only(right: 16, left: 8),
                    child: _buildActionSection(isAvailable, isUsed, isActive, primaryColor, v['id']),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(bool isAvailable, bool isUsed, bool isActive, Color primaryColor, int voucherId) {
    if (isAvailable && !isUsed) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onPressed: () => _useVoucher(voucherId),
        child: const Text("Pakai", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
      );
    } else if (isActive) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_bottom_rounded, color: Colors.white.withOpacity(0.8), size: 28),
          const SizedBox(height: 4),
          const Text("Aktif", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: Colors.white.withOpacity(0.8), size: 28),
          const SizedBox(height: 4),
          const Text("Terpakai", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      );
    }
  }
}