import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ptodolist/core/theme/app_theme.dart';
import 'package:ptodolist/core/utils/color_utils.dart';
import 'package:ptodolist/core/utils/stats_calculator.dart';

class CategoryBreakdown extends StatelessWidget {
  final List<CategoryStat> stats;

  const CategoryBreakdown({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: stats.map((stat) {
        final percent = (stat.rate * 100).round();
        final color = parseHexColor(stat.color);
        final cardBg = (theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.label_outline, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: LinearProgressIndicator(
                        value: stat.rate,
                        minHeight: 4,
                        backgroundColor: AppTheme.surfaceContainerHighest,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percent%',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
