import 'package:flutter/material.dart';

// ================= HELPER: TICKET CLIPPER =================
// Digunakan untuk membuat lubang tiket yang benar-benar terpotong (transparan)
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    // Lubang Lingkaran Atas (posisi horizontal 45)
    path.addOval(Rect.fromCircle(center: const Offset(45, 0), radius: 10));
    // Lubang Lingkaran Bawah (posisi horizontal 45)
    path.addOval(Rect.fromCircle(center: Offset(45, size.height), radius: 10));

    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ================= HELPER: DASHED LINE PAINTER =================
class DashLinePainter extends CustomPainter {
  final Color color;
  DashLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 15;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    while (startY < size.height - 15) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
