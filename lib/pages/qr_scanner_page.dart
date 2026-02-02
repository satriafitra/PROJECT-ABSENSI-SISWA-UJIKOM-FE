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
    final cutOutSize = size.width * 0.8;
    final cutOutTop = (size.height - cutOutSize) / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Kamera penuh
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final String? code = barcode.rawValue;
                if (code == null) continue;
                if (qrCode != code) {
                  setState(() {
                    qrCode = code;
                  });
                }
              }
            },
          ),

          // Semi-transparent overlay
          Container(color: Colors.black38),

          // Area cutout
          Positioned(
            left: size.width * 0.1,
            top: cutOutTop,
            child: Container(
              width: cutOutSize,
              height: cutOutSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 4),
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
              ),
            ),
          ),

          // Scan line animasi
          Positioned(
            left: size.width * 0.1,
            top: cutOutTop,
            child: AnimatedBuilder(
              animation: _lineAnimation,
              builder: (_, __) {
                return Transform.translate(
                  offset: Offset(0, cutOutSize * _lineAnimation.value),
                  child: Container(
                    width: cutOutSize,
                    height: 3,
                    color: Colors.orangeAccent,
                  ),
                );
              },
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Torch / lampu flash
          Positioned(
            bottom: 40,
            right: 30,
            child: IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white, size: 30),
              onPressed: () {
                cameraController.toggleTorch();
              },
            ),
          ),

          // Hasil QR
          if (qrCode != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(20),
                child: Text(
                  'Hasil QR: $qrCode',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
