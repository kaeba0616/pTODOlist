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

  /// 달성률에 따른 색상 반환 (GitHub 잔디 스타일)
  static Color completionColor(double rate, {required bool isLight}) {
    final primary = isLight ? AppTheme.primaryDark : AppTheme.primary;
    final empty = isLight ? const Color(0xFFF2F3F7) : AppTheme.darkCard;

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
        ? (isLight ? const Color(0xFFF2F3F7) : AppTheme.darkBg)
        : completionRate != null
            ? completionColor(completionRate!, isLight: isLight)
            : (isLight ? const Color(0xFFF2F3F7) : AppTheme.darkCard);

    final textColor = isFuture
        ? (isLight ? Colors.grey[400]! : AppTheme.darkTextTertiary)
        : (isLight ? const Color(0xFF111827) : AppTheme.darkTextPrimary);

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
