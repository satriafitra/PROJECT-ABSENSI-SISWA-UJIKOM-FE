import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/session.dart';
import '../providers/theme_provider.dart'; // Pastikan path ini benar

const orangeMain = Color(0xFFFF7A30);

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  String _shortName(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return parts[0];
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil state tema
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final fullName = Session.studentName ?? 'Siswa';
    final shortName = _shortName(fullName);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // NOTIFICATION ICON
            _buildIconButton(
              icon: Icons.notifications_outlined,
              onTap: () {},
              hasBadge: true,
              themeProvider: themeProvider,
            ),

            // PREMIUM PROFILE CARD (Adaptive Glassmorphism)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      isDark 
                          ? Colors.white.withOpacity(0.1) 
                          : Colors.white.withOpacity(0.9),
                      isDark 
                          ? Colors.white.withOpacity(0.05) 
                          : Colors.white.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withOpacity(0.1) 
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [orangeMain, Color(0xFFFF9F68)],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              child: Text(
                                shortName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: orangeMain,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Pagi,',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: themeProvider.subTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  shortName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: themeProvider.textColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // MENU BUTTON
            _buildIconButton(
              icon: Icons.notes_rounded,
              onTap: () => Scaffold.of(context).openEndDrawer(),
              themeProvider: themeProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
    bool hasBadge = false,
  }) {
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon, 
              size: 22, 
              color: themeProvider.textColor,
            ),
          ),
          if (hasBadge)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeProvider.cardColor, 
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}