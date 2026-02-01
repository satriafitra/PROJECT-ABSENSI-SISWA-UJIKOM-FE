import 'package:flutter/material.dart';

const orangeMain = Color(0xFFFF7A30);
const orangeDark = Color(0xFFFF5A1F);
const greySoft = Color(0xFFE0E0E0);

class WeekStatus extends StatelessWidget {
  const WeekStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F'];
    final activeIndex = 2; // contoh: hari aktif (Wednesday)

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(days.length, (index) {
        final isActive = index == activeIndex;

        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              /// DAY TEXT
              Text(
                days[index],
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? orangeMain : Colors.grey,
                ),
              ),
              const SizedBox(height: 6),

              /// CIRCLE STATUS
              Container(
                width: isActive ? 16 : 12,
                height: isActive ? 16 : 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isActive
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [orangeMain, orangeDark],
                        )
                      : null,
                  color: isActive ? null : greySoft,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            blurRadius: 10,
                            color: orangeMain.withOpacity(.45),
                          ),
                        ]
                      : [],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
