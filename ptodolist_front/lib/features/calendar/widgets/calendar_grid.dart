import 'package:flutter/material.dart';
import 'package:ptodolist/features/calendar/widgets/day_cell.dart';

class CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final Map<String, double> completionRates;
  final DateTime today;
  final void Function(int day)? onDayTap;

  const CalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.completionRates,
    required this.today,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // 월요일=1 기준으로 시작 요일 계산 (0-indexed offset)
    final startWeekday = (firstDay.weekday - 1) % 7;

    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      children: [
        // 요일 헤더
        _buildWeekdayHeader(context),
        const SizedBox(height: 4),
        // 날짜 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startWeekday) {
              return const SizedBox.shrink();
            }
            final day = index - startWeekday + 1;
            final date = DateTime(year, month, day);
            final dateStr =
                '${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
            final isFuture = date.isAfter(today);

            return DayCell(
              day: day,
              completionRate: completionRates[dateStr],
              isToday: isToday,
              isFuture: isFuture,
              onTap: () => onDayTap?.call(day),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final theme = Theme.of(context);

    return Row(
      children: weekdays.asMap().entries.map((entry) {
        Color textColor;
        if (entry.key == 5) {
          textColor = const Color(0xFF3B82F6); // 토요일 - info
        } else if (entry.key == 6) {
          textColor = const Color(0xFFEF4444); // 일요일 - error
        } else {
          textColor = theme.colorScheme.onSurfaceVariant;
        }

        return Expanded(
          child: Center(
            child: Text(
              entry.value,
              style: theme.textTheme.labelSmall?.copyWith(color: textColor),
            ),
          ),
        );
      }).toList(),
    );
  }
}
