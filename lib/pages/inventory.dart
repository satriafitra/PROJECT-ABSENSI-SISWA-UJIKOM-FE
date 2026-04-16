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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Voucher Saya",
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

  // ================= EMPTY STATE =================
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined,
              size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Belum ada voucher",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget _buildVoucherCard(Map<String, dynamic> v) {
    final bool isUsed = v['used'] == true;

    final String name = (v['name'] ?? 'Voucher').toString();
    final String description = (v['description'] ?? '-').toString();
    final String category = (v['category'] ?? 'umum').toString();
    final String createdAt = (v['created_at'] ?? '-').toString();

    final int pointsSpent = int.tryParse(
          v['points_spent']?.toString() ?? '0',
        ) ??
        0;

    final Color themeColor = _getCategoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipPath(
        clipper: TicketClipper(),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // ================= TOP =================
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isUsed
                              ? [Colors.grey.shade300, Colors.grey.shade400]
                              : [themeColor.withOpacity(0.8), themeColor],
                        ),
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isUsed ? Colors.grey : Colors.black,
                              decoration:
                                  isUsed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // POINT
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "-$pointsSpent",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                isUsed ? Colors.grey : Colors.redAccent,
                          ),
                        ),
                        const Text(
                          "PTS",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ================= DASH LINE =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(
                    25,
                    (i) => Expanded(
                      child: Container(
                        height: 2,
                        color:
                            i.isEven ? Colors.transparent : Colors.grey[200],
                      ),
                    ),
                  ),
                ),
              ),

              // ================= BOTTOM =================
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                color: isUsed
                    ? Colors.grey.withOpacity(0.05)
                    : themeColor.withOpacity(0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          createdAt,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUsed ? Colors.grey : themeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isUsed ? "TERPAKAI" : "AKTIF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ================= COLOR =================
  Color _getCategoryColor(String category) {
    final c = category.toLowerCase();

    if (c.contains("izin")) return const Color(0xFF6366F1);
    if (c.contains("fasilitas")) return const Color(0xFF10B981);
    return const Color(0xFFF59E0B);
  }

  // ================= ICON =================
  IconData _getCategoryIcon(String category) {
    final c = category.toLowerCase();

    if (c.contains("izin")) return Icons.assignment;
    if (c.contains("fasilitas")) return Icons.home_repair_service;
    return Icons.confirmation_number;
  }
}

// ================= CLIPPER =================
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 10.0;
    final y = size.height * 0.65;

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    path.addOval(Rect.fromCircle(center: Offset(0, y), radius: radius));
    path.addOval(Rect.fromCircle(center: Offset(size.width, y), radius: radius));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}