import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/session.dart';
import '../providers/theme_provider.dart';

const orangeMain = Color(0xFFFE6F47);

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final fullName = Session.studentName ?? 'Siswa';
    final shortName = _shortName(fullName);

    // 🔥 AMBIL DARI PROVIDER (INI YANG PENTING)
    final points = themeProvider.studentPoints;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIconButton(
              icon: Icons.notifications_outlined,
              onTap: () {},
              hasBadge: true,
              themeProvider: themeProvider,
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    colors: [
                      isDark
                          ? Colors.white.withOpacity(0.12)
                          : Colors.white.withOpacity(0.95),
                      isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.8),
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
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
                              backgroundColor:
                                  isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              child: Text(
                                shortName.isNotEmpty
                                    ? shortName[0].toUpperCase()
                                    : 'S',
                                style: const TextStyle(
                                  color: orangeMain,
                                  fontWeight: FontWeight.bold,
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
                                  shortName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.stars,
                                        size: 12, color: Color(0xFFFFB800)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$points Poin',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: themeProvider.subTextColor,
                                      ),
                                    ),
                                  ],
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
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: themeProvider.textColor),
          ),
          if (hasBadge)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                height: 10,
                width: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}