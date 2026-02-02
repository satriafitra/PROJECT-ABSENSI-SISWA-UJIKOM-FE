import 'package:flutter/material.dart';


const orangeMain = Color(0xFFFF7A30);
const orangeSoft = Color(0xFFFFC09A);

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// NOTIFICATION
            const Icon(Icons.notifications_none, size: 26),

            /// HELLO USER (DUMMY)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white.withOpacity(.9),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: orangeSoft,
                    child: Icon(Icons.person,
                        color: orangeMain, size: 16),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Hello Jeremy",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            /// BURGER MENU
            const Icon(Icons.menu, size: 26),
          ],
        ),
      ),
    );
  }
}
