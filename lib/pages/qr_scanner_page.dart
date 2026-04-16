import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
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
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _lineAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutSine),
    );
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _handleQrScan(String rawValue) async {
    if (isProcessing) return;
    isProcessing = true;

    _audioPlayer.play(AssetSource('audio/qr_sound.mp3'));

    try {
      final decoded = jsonDecode(rawValue);
      if (!decoded.containsKey('qr_token')) throw 'QR tidak valid';

      final response = await ApiService.submitAttendance(
        studentId: Session.id!,
        qrToken: decoded['qr_token'],
        createdAt: decoded['created_at'],
      );

      if (response != null && response['status'] == true) {
        if (response['detail'] != null &&
            response['detail']['total_poin_skrg'] != null) {
          int pointBaru = response['detail']['total_poin_skrg'];
          await Session.updatePoints(pointBaru);
          if (mounted) {
            Provider.of<ThemeProvider>(context, listen: false)
                .updatePoints(pointBaru);
          }
        }

        cameraController.stop();
        if (!mounted) return;

        // Tampilkan Feedback Berhasil
        _showModernAlert(
          isSuccess: true,
          message: response['message'] ?? 'Absensi berhasil tercatat!',
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RiwayatAbsensiPage()),
            );
          },
        );
      } else {
        throw response['message'] ?? 'Gagal melakukan absensi';
      }
    } catch (e) {
      isProcessing = false;
      qrCode = null;
      // Tampilkan Feedback Gagal
      _showModernAlert(
        isSuccess: false,
        message: e.toString(),
        onTap: () => Navigator.pop(context),
      );
    }
  }

  // MODIFIKASI: UI Alert Baru yang Mewah & Menarik
  void _showModernAlert({
    required bool isSuccess,
    required String message,
    required VoidCallback onTap,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: isSuccess 
                  ? Colors.white.withOpacity(0.9) 
                  : const Color(0xFF1A1A1A).withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Indikator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.orange.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                    color: isSuccess ? Colors.orange : Colors.redAccent,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                // Judul
                Text(
                  isSuccess ? "Berhasil!" : "Gagal!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.black87 : Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                // Pesan
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSuccess ? Colors.black54 : Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                // Tombol Aksi Mewah
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess ? Colors.orange : Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      isSuccess ? "Lihat Riwayat" : "Coba Lagi",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cutOutSize = size.width * 0.75;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Colors.orange.shade700,
                borderRadius: 24,
                borderLength: 40,
                borderWidth: 8,
                cutOutSize: cutOutSize,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: cutOutSize,
              height: cutOutSize,
              child: AnimatedBuilder(
                animation: _lineAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: cutOutSize * _lineAnimation.value,
                        left: 15,
                        right: 15,
                        child: Column(
                          children: [
                            Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.8),
                                    blurRadius: 15,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.orange.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _glassBtn(Icons.arrow_back_ios_new_rounded,
                    () => Navigator.pop(context)),
                const Text(
                  "QR ATTENDANCE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _glassBtn(Icons.flashlight_on_rounded,
                    () => cameraController.toggleTorch()),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_scanner,
                          color: Colors.orangeAccent, size: 30),
                      const SizedBox(height: 12),
                      const Text(
                        "Scan QR Code Absensi",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Pastikan kode berada di dalam area kotak",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

// QR Scanner Overlay Painter tetap sama...
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.orange,
    this.borderWidth = 8,
    this.borderRadius = 24,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final cutOutRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
              cutOutRect, Radius.circular(borderRadius))),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final double radius = borderRadius;
    final double length = borderLength;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left, cutOutRect.top + radius + length)
        ..lineTo(cutOutRect.left, cutOutRect.top + radius)
        ..arcToPoint(Offset(cutOutRect.left + radius, cutOutRect.top),
            radius: Radius.circular(radius))
        ..lineTo(cutOutRect.left + radius + length, cutOutRect.top),
      borderPaint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - radius - length, cutOutRect.top)
        ..lineTo(cutOutRect.right - radius, cutOutRect.top)
        ..arcToPoint(Offset(cutOutRect.right, cutOutRect.top + radius),
            radius: Radius.circular(radius))
        ..lineTo(cutOutRect.right, cutOutRect.top + radius + length),
      borderPaint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right, cutOutRect.bottom - radius - length)
        ..lineTo(cutOutRect.right, cutOutRect.bottom - radius)
        ..arcToPoint(Offset(cutOutRect.right - radius, cutOutRect.bottom),
            radius: Radius.circular(radius))
        ..lineTo(cutOutRect.right - radius - length, cutOutRect.bottom),
      borderPaint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.left + radius + length, cutOutRect.bottom)
        ..lineTo(cutOutRect.left + radius, cutOutRect.bottom)
        ..arcToPoint(Offset(cutOutRect.left, cutOutRect.bottom - radius),
            radius: Radius.circular(radius))
        ..lineTo(cutOutRect.left, cutOutRect.bottom - radius - length),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) => this;
}