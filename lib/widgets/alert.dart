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
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ZoomIn( // Menggunakan ZoomIn agar muncul membesar dari tengah
            duration: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- ICON AREA DENGAN EFEK MODERN ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Efek Denyut Halus (Pulse)
                      Pulse(
                        infinite: true,
                        duration: const Duration(seconds: 2),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isSuccess ? Colors.green : Colors.red).withOpacity(0.1),
                          ),
                        ),
                      ),
                      // Icon Utama dengan efek Roulette (Putar saat muncul)
                      Roulette(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSuccess 
                                ? [Colors.green.shade400, Colors.green.shade700]
                                : [const Color(0xFFFF6B35), Colors.red.shade700],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isSuccess ? Colors.green : Colors.red).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            isSuccess ? Icons.check_rounded : Icons.priority_high_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // --- TEXT CONTENT ---
                  FadeIn(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeIn(
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- BUTTON DENGAN GRADASI ---
                  FadeInUp(
                    from: 10,
                    delay: const Duration(milliseconds: 500),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: isSuccess 
                            ? [const Color(0xFFFF6B35), const Color(0xFFFF8E62)]
                            : [const Color(0xFFFF6B35), const Color(0xFFFF8E62)],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (onConfirm != null) onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Oke, Siap!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}