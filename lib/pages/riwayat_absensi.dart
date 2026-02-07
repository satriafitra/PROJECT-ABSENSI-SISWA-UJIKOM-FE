import 'package:flutter/material.dart';
import '../utils/session.dart';

/// Helper untuk nama pendek (contoh: Satria Fitra Alamsyah → Satria Fitra)
String getShortName(String? fullName) {
  if (fullName == null || fullName.isEmpty) return '-';

  final parts = fullName.trim().split(' ');
  if (parts.length == 1) return parts[0];

  return '${parts[0]} ${parts[1]}';
}

class RiwayatAbsensiPage extends StatelessWidget {
  const RiwayatAbsensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFFFF5722), size: 18),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
        ),
        title: const Text(
          'KEHADIRAN SISWA',
          style: TextStyle(
            color: Color(0xFFFF5722),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        itemCount: 5,
        itemBuilder: (context, index) {
          final statuses = [
            'HADIR',
            'HADIR',
            'SAKIT',
            'ALPHA',
            'HADIR'
          ];
          return AttendanceItem(status: statuses[index]);
        },
      ),
    );
  }
}

class AttendanceItem extends StatelessWidget {
  final String status;
  const AttendanceItem({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final shortName = getShortName(Session.studentName);
    final kelas = Session.studentClass ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== TANGGAL =====
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 10, top: 10),
          child: Row(
            children: [
              const Icon(Icons.access_time_filled_rounded,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                "Rabu, 12 February 2026",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // ===== CARD =====
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                Row(
                  children: [
                    // ===== SISI KIRI (ORANGE) =====
                    Container(
                      width: 85,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF8A65),
                            Color(0xFFFF5722),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5722).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(4, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFFFF5722),
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    // ===== TENGAH (NAMA & KELAS) =====
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shortName,
                            style: const TextStyle(
                              color: Color(0xFFFF4D00),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  kelas,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge(status: status),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ===== CHARACTER IMAGE (TETAP ADA) =====
                Positioned(
                  right: -10,
                  bottom: -5,
                  child: Transform.scale(
                    scaleX: -1,
                    child: Image.asset(
                      'lib/images/char.png',
                      height: 95,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Divider(color: Color(0x33FF7A50), thickness: 1),
        ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'HADIR':
        bgColor = const Color(0xFFE8F5E9);
        textColor = Colors.green.shade700;
        break;
      case 'SAKIT':
        bgColor = const Color(0xFFFFFDE7);
        textColor = Colors.orange.shade800;
        break;
      default:
        bgColor = const Color(0xFFFFEBEE);
        textColor = Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
