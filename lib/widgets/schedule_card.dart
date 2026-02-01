import 'package:flutter/material.dart';

const orangeMain = Color(0xFFFF7A30);
const textGrey = Color(0xFF9E9E9E);
const textDark = Color(0xFF2E2E2E);

class ScheduleCard extends StatelessWidget {
  final String subject;
  final String teacher;
  final String time;

  const ScheduleCard({
    super.key,
    required this.subject,
    required this.teacher,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: orangeMain,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _info("Teacher", teacher),
              const SizedBox(width: 20),
              Container(height: 28, width: 1, color: Colors.grey.shade300),
              const SizedBox(width: 20),
              _info("Time", time),
            ],
          )
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: textGrey,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: textDark)),
      ],
    );
  }
}
