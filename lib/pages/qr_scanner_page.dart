import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/api_services.dart';
import '../utils/session.dart';
import 'riwayat_absensi.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage>
    with SingleTickerProviderStateMixin {
  String? qrCode;
  bool isProcessing = false;

  late MobileScannerController cameraController;
  late AnimationController _animationController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();

    cameraController = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _handleQrScan(String rawValue) async {
    if (isProcessing) return;
    isProcessing = true;

    try {
      final decoded = jsonDecode(rawValue);

      if (!decoded.containsKey('qr_token')) {
        throw 'QR tidak valid';
      }

      final response = await ApiService.submitAttendance(
        studentId: Session.id!,
        qrToken: decoded['qr_token'],
      );

      if (response != null && response['status'] == true) {
        cameraController.stop();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Absensi berhasil'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const RiwayatAbsensiPage(),
          ),
        );
      } else {
        throw response['message'] ?? 'Gagal melakukan absensi';
      }
    } catch (e) {
      isProcessing = false;
      qrCode = null; // reset agar bisa scan ulang
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cutOutSize = size.width * 0.7;
    final cutOutTop = (size.height - cutOutSize) / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ================= CAMERA =================
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null && qrCode == null) {
                  setState(() => qrCode = barcode.rawValue);
                  _handleQrScan(barcode.rawValue!);
                }
              }
            },
          ),

          // ================= MASK =================
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(color: Colors.black),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: cutOutSize,
                    height: cutOutSize,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= FRAME =================
          Align(
            alignment: Alignment.center,
            child: CustomPaint(
              size: Size(cutOutSize, cutOutSize),
              painter: ScannerFramePainter(),
            ),
          ),

          // ================= LASER =================
          Positioned(
            left: (size.width - cutOutSize) / 2,
            top: cutOutTop,
            child: AnimatedBuilder(
              animation: _lineAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, cutOutSize * _lineAnimation.value),
                  child: Container(
                    width: cutOutSize,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.orangeAccent,
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.7),
                          blurRadius: 20,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ================= HEADER =================
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleBtn(
                  Icons.arrow_back_ios_new_rounded,
                  () => Navigator.pop(context),
                ),
                const Text(
                  "Scan QR Code",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _circleBtn(
                  Icons.flashlight_on_rounded,
                  () => cameraController.toggleTorch(),
                ),
              ],
            ),
          ),

          // ================= FOOTER =================
          Positioned(
            top: cutOutTop + cutOutSize + 40,
            left: 0,
            right: 0,
            child: const Text(
              "Posisikan QR Code di dalam kotak",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black26,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

// ================= FRAME PAINTER =================
class ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 30.0;
    final path = Path();

    path
      ..moveTo(0, len)
      ..lineTo(0, 0)
      ..lineTo(len, 0)
      ..moveTo(size.width - len, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, len)
      ..moveTo(size.width, size.height - len)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - len, size.height)
      ..moveTo(len, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - len);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
