import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class WeekStatus extends StatelessWidget {
  const WeekStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Ambil data poin dari provider
    final int currentPoints = themeProvider.studentPoints;
    
    // Logika Progress: Target per 100 poin
    final int targetPoints = 100;
    final int nextMilestone = ((currentPoints / targetPoints).floor() + 1) * targetPoints;
    final double progressPercent = (currentPoints % targetPoints) / targetPoints;

    const orangeMain = Color(0xFFFF7A30);
    const orangeDark = Color(0xFFFF5A1F);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: orangeMain),
                const SizedBox(width: 6),
                Text(
                  "Next Reward Progress",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            Text(
              "${(progressPercent * 100).toInt()}%",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: orangeMain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Progress Bar Container
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Background Track
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode 
                        ? Colors.white.withOpacity(0.05) 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
                // Active Progress with Gradient
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  height: 12,
                  width: constraints.maxWidth * progressPercent,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [orangeMain, orangeDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: orangeMain.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),

        // Footer Info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$currentPoints PTS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: themeProvider.subTextColor,
              ),
            ),
            Text(
              "Goal: $nextMilestone PTS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: themeProvider.subTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}