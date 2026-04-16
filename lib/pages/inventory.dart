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
    try {
      final res = await ApiService.useVoucher(voucherId: voucherId);

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("1 token berhasil diaktifkan"),
            backgroundColor: Colors.green,
          ),
        );

        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Gagal menggunakan voucher"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Inventory Voucher",
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vouchers.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: vouchers.length,
                  itemBuilder: (context, index) {
                    return _buildVoucherCard(vouchers[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined,
              size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("Belum ada voucher",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(Map<String, dynamic> v) {
    final String status = (v['status'] ?? 'AVAILABLE').toString();
    final bool isActivated = v['attendance_id'] != null;
    final bool isAvailable = status == 'AVAILABLE';

    final String name = (v['name'] ?? 'Voucher').toString();
    final String description = (v['description'] ?? '-').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        // ICON STATUS
        leading: CircleAvatar(
          backgroundColor: isActivated
              ? Colors.green
              : isAvailable
                  ? Colors.orange
                  : Colors.grey,
          child: Icon(
            isActivated
                ? Icons.check
                : isAvailable
                    ? Icons.flash_on
                    : Icons.lock,
            color: Colors.white,
          ),
        ),

        // TEXT
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Text(
              isActivated
                  ? "SUDAH DIPAKAI DI ABSENSI"
                  : isAvailable
                      ? "SIAP DIGUNAKAN"
                      : "TIDAK TERSEDIA",
              style: TextStyle(
                color: isActivated
                    ? Colors.green
                    : isAvailable
                        ? Colors.orange
                        : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),

        // BUTTON
        trailing: (!isAvailable || isActivated)
            ? const Icon(Icons.lock, color: Colors.grey)
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () => _useVoucher(v['id']),
                child: const Text("Gunakan"),
              ),
      ),
    );
  }
}