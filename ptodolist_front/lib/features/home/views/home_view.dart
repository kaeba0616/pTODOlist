import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/core/theme/app_theme.dart';
import 'package:ptodolist/core/utils/color_utils.dart';
import 'package:ptodolist/core/utils/streak_calculator.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/routine/views/routine_form_view.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';
import 'package:ptodolist/features/task/views/task_form_view.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/home/widgets/daily_progress_ring.dart';
import 'package:ptodolist/features/home/widgets/add_bottom_sheet.dart';
import 'package:ptodolist/features/home_widget/services/home_widget_service.dart';

class HomeView extends StatefulWidget {
  final CategoryRepository categoryRepo;
  final RoutineRepository routineRepo;
  final TaskRepository taskRepo;
  final DailyRecordRepository? dailyRecordRepo;
  final HomeWidgetService? homeWidgetService;

  const HomeView({
    super.key,
    required this.categoryRepo,
    required this.routineRepo,
    required this.taskRepo,
    this.dailyRecordRepo,
    this.homeWidgetService,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late DailyRecord _dailyRecord;
  final _today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _initDailyRecord();
  }

  void _initDailyRecord() {
    final todayRoutines = widget.routineRepo.getActiveForDay(
      DateTime.now().weekday,
    );
    if (widget.dailyRecordRepo != null) {
      _dailyRecord = widget.dailyRecordRepo!.getOrCreateToday(todayRoutines);
    } else {
      final activeRoutines = todayRoutines;
      _dailyRecord = DailyRecord(
        date: _today,
        routineCompletions: {for (final r in activeRoutines) r.id: false},
      );
    }
  }

  List<Routine> get _activeRoutines =>
      widget.routineRepo.getActiveForDay(DateTime.now().weekday);

  List<AdditionalTask> get _todayTasks {
    final tasks = widget.taskRepo.getTodayAndOverdue(_today);
    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      final aOverdue = a.targetDate.compareTo(_today) < 0;
      final bOverdue = b.targetDate.compareTo(_today) < 0;
      if (aOverdue != bOverdue) return aOverdue ? -1 : 1;
      if (aOverdue && bOverdue) return a.targetDate.compareTo(b.targetDate);
      return a.order.compareTo(b.order);
    });
    return tasks;
  }

  int get _totalCount => _activeRoutines.length + _todayTasks.length;

  int get _completedCount {
    final routinesDone = _dailyRecord.completedCount;
    final tasksDone = _todayTasks.where((t) => t.isCompleted).length;
    return routinesDone + tasksDone;
  }

  int _getStreak(Routine routine) {
    if (widget.dailyRecordRepo == null) return 0;
    final records = widget.dailyRecordRepo!.getRecordsInRange(
      DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 365))),
      _today,
    );
    return StreakCalculator.currentStreak(
      routineId: routine.id,
      records: records,
      today: _today,
      activeDays: routine.activeDays,
    );
  }

  Category? _getCategoryFor(String categoryId) {
    return widget.categoryRepo.getById(categoryId);
  }

  void _toggleRoutine(String routineId) {
    setState(() {
      _dailyRecord = _dailyRecord.toggleRoutine(routineId);
      widget.dailyRecordRepo?.save(_dailyRecord);
    });
    widget.homeWidgetService?.updateWidgetData();
  }

  void _toggleTask(String taskId) {
    setState(() {
      widget.taskRepo.toggleComplete(taskId);
    });
    widget.homeWidgetService?.updateWidgetData();
  }

  Future<void> _editRoutine(Routine routine) async {
    final categories = widget.categoryRepo.getAll();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RoutineFormView(routine: routine, categories: categories),
    );
    if (result != null && mounted) {
      setState(() {
        final updated = routine.copyWith(
          title: result['title'],
          categoryId: result['categoryId'],
          isActive: result['isActive'],
          subtasks: List<String>.from(result['subtasks'] ?? []),
          priority: result['priority'] ?? routine.priority,
          iconCodePoint: () => result['iconCodePoint'] as int?,
          activeDays: List<int>.from(result['activeDays'] ?? routine.activeDays),
        );
        widget.routineRepo.update(updated);
        if (!updated.isActive) {
          final completions = Map<String, bool>.from(
            _dailyRecord.routineCompletions,
          );
          completions.remove(updated.id);
          _dailyRecord = _dailyRecord.copyWith(routineCompletions: completions);
          widget.dailyRecordRepo?.save(_dailyRecord);
        }
      });
    }
  }

  Future<void> _editTask(AdditionalTask task) async {
    final categories = widget.categoryRepo.getAll();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskFormView(task: task, categories: categories),
    );
    if (result != null && mounted) {
      setState(() {
        final updated = task.copyWith(
          title: result['title'],
          categoryId: result['categoryId'],
          subtasks: List<String>.from(result['subtasks'] ?? []),
          targetDate: result['targetDate'] as String?,
        );
        widget.taskRepo.update(updated);
      });
    }
  }

  Future<void> _showAddSheet() async {
    final type = await showModalBottomSheet<AddType>(
      context: context,
      builder: (_) => const AddBottomSheet(),
    );
    if (type == null || !mounted) return;

    final categories = widget.categoryRepo.getAll();

    if (type == AddType.routine) {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (_) => RoutineFormView(categories: categories),
      );
      if (result != null && mounted) {
        setState(() {
          final id = widget.routineRepo.add(
            title: result['title'],
            categoryId: result['categoryId'],
            subtasks: List<String>.from(result['subtasks'] ?? []),
            priority: result['priority'] ?? 1,
            iconCodePoint: result['iconCodePoint'] as int?,
            activeDays: List<int>.from(result['activeDays'] ?? []),
          );
          final updated = Map<String, bool>.from(
            _dailyRecord.routineCompletions,
          );
          updated[id] = false;
          _dailyRecord = _dailyRecord.copyWith(routineCompletions: updated);
        });
      }
    } else {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (_) => TaskFormView(categories: categories),
      );
      if (result != null && mounted) {
        setState(() {
          widget.taskRepo.add(
            title: result['title'],
            categoryId: result['categoryId'],
            subtasks: List<String>.from(result['subtasks'] ?? []),
            targetDate: result['targetDate'] as String?,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: isDark ? const Color(0xFFB1F0CE) : AppTheme.brandAccent,
            ),
            const SizedBox(width: 8),
            Text('pTODOlist'),
          ],
        ),
      ),
      body: _totalCount == 0
          ? _buildEmptyState(theme, isDark)
          : _buildContent(theme, isDark),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('아직 할 일이 없어요', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '+ 버튼으로 추가해보세요',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        const SizedBox(height: 8),

        // Welcome & Progress Ring Section
        _buildWelcomeSection(theme, isDark),
        const SizedBox(height: 32),

        // Routines Section
        if (_activeRoutines.isNotEmpty) ...[
          _buildSectionHeader(
            theme,
            title: '오늘의 루틴',
            badge: '반복',
            badgeColor: AppTheme.tertiaryContainer,
            badgeTextColor: AppTheme.tertiary,
          ),
          const SizedBox(height: 12),
          ..._activeRoutines.map((routine) {
            final isDone = _dailyRecord.isRoutineCompleted(routine.id);
            final category = _getCategoryFor(routine.categoryId);
            final streak = _getStreak(routine);
            return _buildRoutineTile(
              routine: routine,
              isDone: isDone,
              category: category,
              streak: streak,
              isDark: isDark,
              theme: theme,
            );
          }),
          const SizedBox(height: 24),
        ],

        // Tasks Section
        if (_todayTasks.isNotEmpty) ...[
          _buildSectionHeader(
            theme,
            title: '추가 할 일',
            trailing: GestureDetector(
              onTap: _showAddSheet,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 2),
                  Text(
                    '새 할 일',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._todayTasks.map((task) {
            final category = _getCategoryFor(task.categoryId);
            final isOverdue = !task.isCompleted && task.targetDate.compareTo(_today) < 0;
            final overdueDays = isOverdue
                ? DateTime.now().difference(DateTime.parse(task.targetDate)).inDays
                : 0;
            return _buildTaskCard(
              task: task,
              category: category,
              overdueDays: overdueDays,
              isDark: isDark,
              theme: theme,
            );
          }),
          const SizedBox(height: 24),
        ],

        // Quote Section
        _buildQuoteSection(theme, isDark),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, bool isDark) {
    final remaining = _totalCount - _completedCount;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THE DIGITAL SANCTUARY',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Today's ",
                      style: GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight: FontWeight.w200,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Progress',
                      style: GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                remaining > 0
                    ? '$remaining개 남았어요. 조금만 더 힘내세요!'
                    : '오늘의 할 일을 모두 완료했어요!',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        DailyProgressRing(completed: _completedCount, total: _totalCount),
      ],
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme, {
    required String title,
    String? badge,
    Color? badgeColor,
    Color? badgeTextColor,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor ?? AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                badge.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: badgeTextColor ?? theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildRoutineTile({
    required Routine routine,
    required bool isDone,
    required Category? category,
    required int streak,
    required bool isDark,
    required ThemeData theme,
  }) {
    final bgColor = isDone
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
        : (isDark ? const Color(0xFF22252A) : AppTheme.surfaceContainerLowest);

    return Dismissible(
      key: Key(routine.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() {
          widget.routineRepo.delete(routine.id);
          final updated = Map<String, bool>.from(_dailyRecord.routineCompletions);
          updated.remove(routine.id);
          _dailyRecord = _dailyRecord.copyWith(routineCompletions: updated);
        });
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _editRoutine(routine),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => _toggleRoutine(routine.id),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDone ? theme.colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: isDone
                        ? null
                        : Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                  ),
                  child: isDone
                      ? Icon(Icons.check, size: 16, color: theme.colorScheme.onPrimary)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDone
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (routine.subtasks.isNotEmpty || streak >= 2)
                      const SizedBox(height: 2),
                    if (routine.subtasks.isNotEmpty || streak >= 2)
                      Row(
                        children: [
                          if (routine.subtasks.isNotEmpty)
                            Text(
                              '${routine.subtasks.length}개 하위작업',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          if (routine.subtasks.isNotEmpty && streak >= 2)
                            Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          if (streak >= 2) ...[
                            const Icon(
                              Icons.local_fire_department,
                              color: Color(0xFFF59E0B),
                              size: 13,
                            ),
                            Text(
                              ' $streak일 연속',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFFF59E0B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
              // Category dot
              if (category != null)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: parseHexColor(category.color),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required AdditionalTask task,
    required Category? category,
    required int overdueDays,
    required bool isDark,
    required ThemeData theme,
  }) {
    final cardColor = isDark ? const Color(0xFF22252A) : AppTheme.surfaceContainerLowest;
    final iconBg = category != null
        ? parseHexColor(category.color).withValues(alpha: 0.1)
        : theme.colorScheme.secondaryContainer;
    final iconColor = category != null
        ? parseHexColor(category.color)
        : theme.colorScheme.secondary;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() {
          widget.taskRepo.delete(task.id);
        });
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _editTask(task),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  task.isCompleted ? Icons.check : Icons.assignment_outlined,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                        decoration:
                            task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (overdueDays > 0 || task.subtasks.isNotEmpty)
                      Row(
                        children: [
                          if (overdueDays > 0)
                            Text(
                              'D+$overdueDays',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (overdueDays > 0 && task.subtasks.isNotEmpty)
                            Text(' • ',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurfaceVariant)),
                          if (task.subtasks.isNotEmpty)
                            Text(
                              '${task.subtasks.length}개 하위작업',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              // Completion circle
              GestureDetector(
                onTap: () => _toggleTask(task.id),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: task.isCompleted
                        ? null
                        : Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                            width: 2,
                          ),
                  ),
                  child: task.isCompleted
                      ? Icon(Icons.check, size: 16, color: theme.colorScheme.onPrimary)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1C1E) : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.eco,
            size: 32,
            color: isDark ? const Color(0xFF56634A) : AppTheme.tertiary,
          ),
          const SizedBox(height: 12),
          Text(
            '"작은 습관이 큰 변화를 만듭니다.\n오늘도 한 걸음 더 나아가세요."',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
