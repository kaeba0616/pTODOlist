import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/core/utils/color_utils.dart';

class DayDetailSheet extends StatelessWidget {
  final DateTime date;
  final DailyRecord? record;
  final List<Routine> routines;
  final List<AdditionalTask> tasks;
  final List<Category> categories;

  const DayDetailSheet({
    super.key,
    required this.date,
    this.record,
    required this.routines,
    required this.tasks,
    required this.categories,
  });

  Category? _findCategory(String categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('M월 d일 EEEE', 'ko_KR').format(date);

    final completedCount = record?.completedCount ?? 0;
    final totalCount = record?.totalCount ?? 0;
    final rate = record?.completionRate ?? 0.0;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // 드래그 핸들
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 날짜 헤더
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(dateStr, style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 16),

              // 진행률 바
              if (record != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: rate,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _progressColor(rate),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$completedCount/$totalCount (${(rate * 100).round()}%)',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // 루틴 섹션
              if (record != null && record!.totalCount > 0) ...[
                Text('루틴', style: theme.textTheme.titleSmall),
                const Divider(),
                ...record!.routineCompletions.entries.map((entry) {
                  final routine = _findRoutine(entry.key);
                  final category = routine != null
                      ? _findCategory(routine.categoryId)
                      : null;
                  final completed = entry.value;

                  return ListTile(
                    dense: true,
                    leading: Icon(
                      completed ? Icons.check_circle : Icons.cancel,
                      color: completed
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                    title: Text(
                      routine?.title ?? '(삭제된 루틴)',
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: category != null
                        ? Chip(
                            label: Text(
                              category.name,
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: parseHexColor(category.color)
                                .withValues(alpha: 0.2),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          )
                        : null,
                  );
                }),
                const SizedBox(height: 16),
              ],

              // 할 일 섹션
              if (tasks.isNotEmpty) ...[
                Text('할 일', style: theme.textTheme.titleSmall),
                const Divider(),
                ...tasks.map((task) {
                  final category = _findCategory(task.categoryId);
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      task.isCompleted ? Icons.check_circle : Icons.cancel,
                      color: task.isCompleted
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                    title: Text(
                      task.title,
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: category != null
                        ? Chip(
                            label: Text(
                              category.name,
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: parseHexColor(category.color)
                                .withValues(alpha: 0.2),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          )
                        : null,
                  );
                }),
              ],

              // 데이터 없음
              if (record == null && tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.event_busy,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          '이 날의 기록이 없습니다',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Routine? _findRoutine(String routineId) {
    try {
      return routines.firstWhere((r) => r.id == routineId);
    } catch (_) {
      return null;
    }
  }

  Color _progressColor(double rate) {
    if (rate >= 1.0) return const Color(0xFF10B981);
    if (rate >= 0.5) return const Color(0xFF4F46E5);
    return const Color(0xFFF59E0B);
  }
}
