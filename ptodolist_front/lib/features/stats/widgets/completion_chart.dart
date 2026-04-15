import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ptodolist/core/theme/app_theme.dart';
import 'package:ptodolist/core/utils/stats_calculator.dart';

class CompletionChart extends StatelessWidget {
  final List<DayStat> stats;

  const CompletionChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barColor = theme.colorScheme.primary;
    final trackColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : AppTheme.primaryContainer.withValues(alpha: 0.4);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}%',
                GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= stats.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    stats[index].label,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: stats.asMap().entries.map((entry) {
          final rate = entry.value.rate * 100;
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: 100,
                color: trackColor,
                width: 14,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                rodStackItems: [
                  BarChartRodStackItem(0, rate, barColor),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
