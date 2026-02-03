import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage>
    with SingleTickerProviderStateMixin {
  String? qrCode;
  late MobileScannerController cameraController;

  late AnimationController _animationController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();

    cameraController = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cutOutSize = size.width * 0.7; // Ukuran kotak scanner
    final cutOutTop = (size.height - cutOutSize) / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Kamera Penuh
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() {
                    qrCode = barcode.rawValue;
                  });
                  // Tambahkan feedback getaran atau suara jika perlu
                  debugPrint('Barcode found! ${barcode.rawValue}');
                }
              }
            },
          ),

          // 2. Background Overlay Gelap dengan Lubang (Masking)
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
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

          // 3. Scanner Frame (Garis di Pojok-Pojok)
          Align(
            alignment: Alignment.center,
            child: CustomPaint(
              size: Size(cutOutSize, cutOutSize),
              painter: ScannerFramePainter(),
            ),
          ),

          // 4. Animasi Laser Glow Orange
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.8),
                          blurRadius: 15,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.5),
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                      ],
                      gradient: const LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.orangeAccent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 5. Tombol Atas (Back & Flash)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circularButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const Text(
                  "Scan QR Code",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _circularButton(
                  icon: Icons.flashlight_on_rounded,
                  onTap: () => cameraController.toggleTorch(),
                ),
              ],
            ),
          ),

          // 6. Label Petunjuk Bawah
          Positioned(
            top: cutOutTop + cutOutSize + 40,
            left: 0,
            right: 0,
            child: const Text(
              "Posisikan QR Code di dalam kotak",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // 7. Pop-up Hasil QR (Jika terdeteksi)
          if (qrCode != null)
            Positioned(
              bottom: 50,
              left: 30,
              right: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'QR Terdeteksi!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$qrCode',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: StadiumBorder(),
                      ),
                      onPressed: () => setState(() => qrCode = null),
                      child: const Text("Scan Lagi", style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _circularButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black26,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// --- Custom Painter untuk Frame Pojok ---
class ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double len = 30; // Panjang garis pojok

    // Pojok Kiri Atas
    path.moveTo(0, len);
    path.lineTo(0, 0);
    path.lineTo(len, 0);

    // Pojok Kanan Atas
    path.moveTo(size.width - len, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, len);

    // Pojok Kanan Bawah
    path.moveTo(size.width, size.height - len);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - len, size.height);

    // Pojok Kiri Bawah
    path.moveTo(len, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height - len);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}