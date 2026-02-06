import 'package:flutter/material.dart';
import '../utils/session.dart';

const orangeMain = Color(0xFFFF7A30);
const orangeSoft = Color(0xFFFFC09A);

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
    final fullName = Session.studentName ?? 'Siswa';
    final shortName = _shortName(fullName);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.notifications_none, size: 26),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withOpacity(.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: orangeSoft,
                    child: Icon(Icons.person, color: orangeMain, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hello $shortName',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),

            /// Tombol Menu untuk buka Sidebar
            IconButton(
              icon: const Icon(Icons.menu_rounded, size: 28, color: Colors.black87),
              onPressed: () {
                // Mencari scaffold terdekat dan membuka endDrawer
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }
}