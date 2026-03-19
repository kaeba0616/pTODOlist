import 'package:flutter/material.dart';

class StreakBanner extends StatelessWidget {
  final int streakDays;

  const StreakBanner({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    if (streakDays <= 0) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Color(0xFFF59E0B),
          ),
          const SizedBox(width: 8),
          Text(
            '$streakDays일 연속 달성 중',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
