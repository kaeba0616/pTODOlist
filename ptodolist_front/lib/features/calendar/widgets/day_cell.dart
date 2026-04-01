import 'package:flutter/material.dart';
import 'package:ptodolist/core/theme/app_theme.dart';

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

  static Color completionColor(double rate, {required bool isLight}) {
    final primary = isLight ? AppTheme.primary : const Color(0xFFB1F0CE);
    final empty = isLight ? AppTheme.surfaceContainerLow : const Color(0xFF22252A);

    if (rate <= 0) return empty;
    if (rate <= 0.25) return primary.withValues(alpha: 0.15);
    if (rate <= 0.50) return primary.withValues(alpha: 0.35);
    if (rate <= 0.75) return primary.withValues(alpha: 0.6);
    return primary;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final bgColor = isFuture
        ? (isLight ? AppTheme.surfaceContainerLow : const Color(0xFF0C0F10))
        : completionRate != null
            ? completionColor(completionRate!, isLight: isLight)
            : (isLight ? AppTheme.surfaceContainerLow : const Color(0xFF22252A));

    final textColor = isFuture
        ? (isLight ? AppTheme.outlineVariant : const Color(0xFF6B7280))
        : (isLight ? AppTheme.onSurface : const Color(0xFFF1F4F5));

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
