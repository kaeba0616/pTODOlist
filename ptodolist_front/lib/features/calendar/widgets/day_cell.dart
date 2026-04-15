import 'package:flutter/material.dart';

class DayCell extends StatelessWidget {
  final int day;
  final double? completionRate;
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;

  const DayCell({
    super.key,
    required this.day,
    this.completionRate,
    this.isToday = false,
    this.isFuture = false,
    this.onTap,
  });

  static Color completionColor(double rate, {required ColorScheme colorScheme}) {
    final primary = colorScheme.primary;
    final empty = colorScheme.surfaceContainerLow;

    if (rate <= 0) return empty;
    if (rate <= 0.25) return primary.withValues(alpha: 0.15);
    if (rate <= 0.50) return primary.withValues(alpha: 0.35);
    if (rate <= 0.75) return primary.withValues(alpha: 0.6);
    return primary;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bgColor = isFuture
        ? colorScheme.surfaceContainerLowest
        : completionRate != null
            ? completionColor(completionRate!, colorScheme: colorScheme)
            : colorScheme.surfaceContainerLow;

    final textColor = isFuture
        ? colorScheme.outlineVariant
        : colorScheme.onSurface;

    return GestureDetector(
      onTap: isFuture ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
