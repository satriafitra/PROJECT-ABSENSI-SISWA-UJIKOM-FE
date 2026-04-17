import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../utils/session.dart';

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
      setState(() {
        vouchers = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        vouchers = [];
        isLoading = false;
      });
    }
  }

  Future<void> _useVoucher(int voucherId) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await ApiService.useVoucher(voucherId: voucherId);
      Navigator.pop(context); // Close loading dialog

      if (res['success'] == true) {
        _showSnackBar("Voucher berhasil diaktifkan", Colors.green);
        fetchData();
      } else {
        _showSnackBar(res['message'] ?? "Gagal menggunakan voucher", Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar("Terjadi kesalahan koneksi", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Light greyish-blue background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 203, 119, 17), Color.fromARGB(255, 255, 174, 35)], // Modern Gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Voucher Saya",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : vouchers.isEmpty
                ? _buildEmptyState()
                : _buildListView(),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        return _buildModernVoucherCard(vouchers[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.confirmation_number_outlined, size: 100, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          const Text(
            "Belum ada voucher tersedia",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          const Text("Cek kembali nanti ya!", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildModernVoucherCard(Map<String, dynamic> v) {
    final String status = (v['status'] ?? 'AVAILABLE').toString();
    final bool isUsed = v['attendance_id'] != null;
    final bool isActive = status == 'ACTIVE';
    final bool isAvailable = status == 'AVAILABLE';

    // UI Configuration based on status
    Color themeColor = Colors.orange;
    String statusText = "SIAP DIGUNAKAN";
    IconData iconData = Icons.local_activity;

    if (isUsed) {
      themeColor = Colors.grey;
      statusText = "SUDAH TERPAKAI";
      iconData = Icons.check_circle;
    } else if (isActive) {
      themeColor = Colors.blue;
      statusText = "SEDANG AKTIF";
      iconData = Icons.timer;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative Circle for "Ticket" feel
            Positioned(
              left: -20,
              top: 40,
              child: CircleAvatar(radius: 12, backgroundColor: const Color(0xFFF0F2F5)),
            ),
            Positioned(
              right: -20,
              top: 40,
              child: CircleAvatar(radius: 12, backgroundColor: const Color(0xFFF0F2F5)),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon Section
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(iconData, color: themeColor, size: 30),
                  ),
                  const SizedBox(width: 16),

                  // Content Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v['name'] ?? 'Voucher',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          v['description'] ?? '-',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(color: themeColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Button
                  if (isAvailable && !isUsed)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () => _useVoucher(v['id']),
                      child: const Text("Pakai", style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  else if (isActive)
                    const Icon(Icons.hourglass_bottom, color: Colors.blue)
                  else
                    const Icon(Icons.lock_clock_outlined, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}