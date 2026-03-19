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

  /// 달성률에 따른 색상 반환 (GitHub 잔디 스타일)
  static Color completionColor(double rate, {required bool isLight}) {
    const primary = Color(0xFF4F46E5);
    final empty = isLight ? const Color(0xFFF3F4F6) : const Color(0xFF374151);

    if (rate <= 0) return empty;
    if (rate <= 0.25) return primary.withValues(alpha: 0.2);
    if (rate <= 0.50) return primary.withValues(alpha: 0.4);
    if (rate <= 0.75) return primary.withValues(alpha: 0.6);
    return primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.findAncestorWidgetOfExactType<MaterialApp>() != null;
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final bgColor = isFuture
        ? (isLight ? Colors.grey[100]! : Colors.grey[800]!)
        : completionRate != null
            ? completionColor(completionRate!, isLight: isLight)
            : (isLight ? const Color(0xFFF3F4F6) : const Color(0xFF374151));

    final textColor = isFuture
        ? (isLight ? Colors.grey[400]! : Colors.grey[600]!)
        : (isLight ? const Color(0xFF111827) : const Color(0xFFF9FAFB));

    return GestureDetector(
      onTap: isFuture ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
