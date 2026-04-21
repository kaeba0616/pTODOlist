import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/core/utils/color_utils.dart';

class DayDetailSheet extends StatefulWidget {
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

  @override
  State<DayDetailSheet> createState() => _DayDetailSheetState();
}

class _DayDetailSheetState extends State<DayDetailSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Category? _findCategory(String categoryId) {
    try {
      return widget.categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  Routine? _findRoutine(String routineId) {
    try {
      return widget.routines.firstWhere((r) => r.id == routineId);
    } catch (_) {
      return null;
    }
  }

  Color _progressColor(double rate) {
    if (rate >= 1.0) return const Color(0xFF10B981);
    if (rate >= 0.5) return const Color(0xFF4F46E5);
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('M월 d일 EEEE', 'ko_KR').format(widget.date);

    final record = widget.record;
    final completedCount = record?.completedCount ?? 0;
    final totalCount = record?.totalCount ?? 0;
    final rate = record?.completionRate ?? 0.0;

    final routineEntries = record?.routineCompletions.entries.toList() ?? [];
    final routineCount = routineEntries.length;
    final taskCount = widget.tasks.length;
    final isEmpty = routineCount == 0 && taskCount == 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(dateStr, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
              if (record != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: rate,
                            minHeight: 8,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
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
                ),
              ],
              const SizedBox(height: 12),
              if (isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                )
              else ...[
                TabBar(
                  controller: _tabController,
                  tabs: [
                    _buildTab('루틴', routineCount),
                    _buildTab('할 일', taskCount),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRoutineList(theme, routineEntries),
                      _buildTaskList(theme),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      height: 44,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoutineList(
      ThemeData theme, List<MapEntry<String, bool>> entries) {
    if (entries.isEmpty) {
      return _buildEmptyTab(theme, '이 날 예정된 루틴이 없습니다');
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      children: entries.map((entry) {
        final routine = _findRoutine(entry.key);
        final category =
            routine != null ? _findCategory(routine.categoryId) : null;
        final completed = entry.value;
        return ListTile(
          dense: true,
          leading: Icon(
            completed ? Icons.check_circle : Icons.cancel_outlined,
            color: completed
                ? const Color(0xFF10B981)
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          title: Text(
            routine?.title ?? '(삭제된 루틴)',
            style: theme.textTheme.bodyLarge?.copyWith(
              decoration: completed ? TextDecoration.lineThrough : null,
              color: completed
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface,
            ),
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
      }).toList(),
    );
  }

  Widget _buildTaskList(ThemeData theme) {
    if (widget.tasks.isEmpty) {
      return _buildEmptyTab(theme, '이 날 등록된 할 일이 없습니다');
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      children: widget.tasks.map((task) {
        final category = _findCategory(task.categoryId);
        return ListTile(
          dense: true,
          leading: Icon(
            task.isCompleted ? Icons.check_circle : Icons.cancel_outlined,
            color: task.isCompleted
                ? const Color(0xFF10B981)
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          title: Text(
            task.title,
            style: theme.textTheme.bodyLarge?.copyWith(
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface,
            ),
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
      }).toList(),
    );
  }

  Widget _buildEmptyTab(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
