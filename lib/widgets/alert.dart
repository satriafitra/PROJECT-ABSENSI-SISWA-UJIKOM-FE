import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class CoolAlert {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required bool isSuccess,
    VoidCallback? onConfirm,
  }) {
    // Parsing data untuk tampilan sukses
    String displayNama = "";
    String displayKelas = "";
    
    if (isSuccess) {
      List<String> msgParts = message.split('\n');
      displayNama = msgParts.isNotEmpty ? msgParts[0] : 'Siswa';
      displayKelas = msgParts.length > 1 ? msgParts.last : '-';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: isSuccess 
            ? ZoomIn(duration: const Duration(milliseconds: 400), child: _buildContent(context, isSuccess, title, message, displayNama, displayKelas, onConfirm))
            : ShakeX(duration: const Duration(milliseconds: 500), child: _buildContent(context, isSuccess, title, message, displayNama, displayKelas, onConfirm)),
        );
      },
    );
  }

  static Widget _buildContent(BuildContext context, bool isSuccess, String title, String message, String nama, String kelas, VoidCallback? onConfirm) {
    // Color Palette
    const primaryOrange = Color(0xFFFF6B35);
    const secondaryOrange = Color(0xFFFF8E62);
    final errorColor = Colors.red.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- ICON AREA CUSTOM ANIMATION ---
          Stack(
            alignment: Alignment.center,
            children: [
              FadeIn(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (isSuccess ? primaryOrange : errorColor).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              ElasticIn(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSuccess 
                          ? [primaryOrange, secondaryOrange] 
                          : [errorColor, Colors.red.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isSuccess ? primaryOrange : errorColor).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_rounded : Icons.priority_high_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // --- TITLE (Font Size diperkecil agar elegan) ---
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F1F1F),
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 12),

          // --- CONTENT AREA ---
          if (isSuccess) ...[
            // Info Card yang lebih clean
            FadeInUp(
              from: 15,
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withOpacity(0.03)),
                ),
                child: Column(
                  children: [
                    _buildRowInfo(Icons.person_outline_rounded, "NAMA", nama),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, thickness: 0.5),
                    ),
                    _buildRowInfo(Icons.school_outlined, "KELAS", kelas),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Pesan Error Simple
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          // --- ACTION BUTTON ---
          FadeInUp(
            from: 10,
            delay: const Duration(milliseconds: 400),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onConfirm != null) onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? primaryOrange : errorColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isSuccess ? "Lanjutkan" : "Coba Kembali",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildRowInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFFF6B35).withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.grey.shade400,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600, 
                  color: Color(0xFF333333),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}