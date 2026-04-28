import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/features/social/providers/social_providers.dart';
import 'package:ptodolist/features/social/services/daily_share_sync_service.dart';
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
import 'package:ptodolist/features/home/data/daily_quotes.dart';
import 'package:ptodolist/features/home_widget/services/home_widget_service.dart';

class HomeView extends ConsumerStatefulWidget {
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
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with SingleTickerProviderStateMixin {
  late DailyRecord _dailyRecord;
  late final TabController _tabController;
  final _today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _initDailyRecord();
    // 앱 시작 시 한 번 sync. 에러일 때만 SnackBar (성공 시 조용함)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await ref.read(dailyShareSyncServiceProvider).syncToday(
            record: _dailyRecord,
            activeRoutines: _activeRoutines,
          );
      if (!mounted) return;
      if (result is SyncedFailed) _showSyncSnack(result);
    });
  }

  void _showSyncSnack(SyncResult result) {
    final msg = switch (result) {
      SyncedOk(:final docId) => '✓ 동기화: $docId',
      SyncedSkipped(:final reason) => '⚠ 동기화 스킵: $reason',
      SyncedDeleted() => '🚫 비공개 모드 — 데이터 삭제',
      SyncedFailed(:final error) => '✗ 동기화 실패: $error',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  List<Routine> get _sortedRoutines {
    final routines = List<Routine>.from(_activeRoutines);
    routines.sort((a, b) {
      final aDone = _dailyRecord.isRoutineCompleted(a.id);
      final bDone = _dailyRecord.isRoutineCompleted(b.id);
      if (aDone != bDone) return aDone ? 1 : -1;
      return a.order.compareTo(b.order);
    });
    return routines;
  }

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

  List<AdditionalTask> get _upcomingTasks =>
      widget.taskRepo.getUpcoming(_today);

  int get _totalCount => _activeRoutines.length + _todayTasks.length;

  int get _completedCount {
    final routinesDone = _dailyRecord.completedCount;
    final tasksDone = _todayTasks.where((t) => t.isCompleted).length;
    return routinesDone + tasksDone;
  }

  int _getStreak(Routine routine) {
    if (widget.dailyRecordRepo == null) return 0;
    final records = widget.dailyRecordRepo!.getRecordsInRange(
      DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().subtract(const Duration(days: 365))),
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
      _saveDailyRecordAndSync();
    });
    widget.homeWidgetService?.updateWidgetData();
  }

  void _saveDailyRecordAndSync() {
    widget.dailyRecordRepo?.save(_dailyRecord);
    final activeRoutines =
        widget.routineRepo.getAll().where((r) => r.isActive).toList();
    // fire-and-forget — SnackBar 로 결과 노출 (디버깅 단계)
    () async {
      final result = await ref.read(dailyShareSyncServiceProvider).syncToday(
            record: _dailyRecord,
            activeRoutines: activeRoutines,
          );
      if (mounted) _showSyncSnack(result);
    }();
  }

  void _toggleTask(String taskId) {
    setState(() {
      widget.taskRepo.toggleComplete(taskId);
    });
    widget.homeWidgetService?.updateWidgetData();
  }

  Future<void> _toggleSubtask(String taskId, int index) async {
    await widget.taskRepo.toggleSubtask(taskId, index);
    if (mounted) setState(() {});
    widget.homeWidgetService?.updateWidgetData();
  }

  Future<void> _editRoutine(Routine routine) async {
    final freshRoutine = widget.routineRepo.getById(routine.id) ?? routine;
    final categories = widget.categoryRepo.getAll();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          RoutineFormView(routine: freshRoutine, categories: categories),
    );
    if (result == null || !mounted) return;

    if (result['_action'] == 'delete') {
      widget.routineRepo.delete(freshRoutine.id);
      setState(() {
        final completions = Map<String, bool>.from(
          _dailyRecord.routineCompletions,
        );
        completions.remove(freshRoutine.id);
        _dailyRecord = _dailyRecord.copyWith(routineCompletions: completions);
        _saveDailyRecordAndSync();
      });
      widget.homeWidgetService?.updateWidgetData();
      return;
    }

    final updated = freshRoutine.copyWith(
      title: result['title'],
      categoryId: result['categoryId'],
      isActive: result['isActive'],
      subtasks: List<String>.from(result['subtasks'] ?? []),
      priority: result['priority'] ?? freshRoutine.priority,
      iconCodePoint: () => result['iconCodePoint'] as int?,
      activeDays: List<int>.from(
        result['activeDays'] ?? freshRoutine.activeDays,
      ),
    );
    await widget.routineRepo.update(updated);
    if (mounted) {
      setState(() {
        if (!updated.isActive) {
          final completions = Map<String, bool>.from(
            _dailyRecord.routineCompletions,
          );
          completions.remove(updated.id);
          _dailyRecord = _dailyRecord.copyWith(routineCompletions: completions);
          _saveDailyRecordAndSync();
        }
      });
    }
  }

  Future<void> _editTask(AdditionalTask task) async {
    final freshTask = widget.taskRepo.getById(task.id) ?? task;
    final categories = widget.categoryRepo.getAll();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskFormView(task: freshTask, categories: categories),
    );
    if (result == null || !mounted) return;

    if (result['_action'] == 'delete') {
      widget.taskRepo.delete(freshTask.id);
      setState(() {});
      widget.homeWidgetService?.updateWidgetData();
      return;
    }

    final updated = freshTask.copyWith(
      title: result['title'],
      categoryId: result['categoryId'],
      subtasks: List<String>.from(result['subtasks'] ?? []),
      targetDate: result['targetDate'] as String?,
    );
    await widget.taskRepo.update(updated);
    if (mounted) setState(() {});
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
        final id = await widget.routineRepo.add(
          title: result['title'],
          categoryId: result['categoryId'],
          subtasks: List<String>.from(result['subtasks'] ?? []),
          priority: result['priority'] ?? 1,
          iconCodePoint: result['iconCodePoint'] as int?,
          activeDays: List<int>.from(result['activeDays'] ?? []),
        );
        if (mounted) {
          setState(() {
            final updated = Map<String, bool>.from(
              _dailyRecord.routineCompletions,
            );
            updated[id] = false;
            _dailyRecord = _dailyRecord.copyWith(routineCompletions: updated);
          });
        }
      }
    } else {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (_) => TaskFormView(categories: categories),
      );
      if (result != null && mounted) {
        await widget.taskRepo.add(
          title: result['title'],
          categoryId: result['categoryId'],
          subtasks: List<String>.from(result['subtasks'] ?? []),
          targetDate: result['targetDate'] as String?,
        );
        if (mounted) setState(() {});
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
      body: _buildContent(theme, isDark),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  static const double _headerExpandedHeight = 164;
  static const double _headerCollapsedHeight = 44;

  Widget _buildContent(ThemeData theme, bool isDark) {
    final routineCount = _activeRoutines.length;
    final todayCount = _todayTasks.length;
    final upcomingCount = _upcomingTasks.length;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              pinned: true,
              floating: false,
              automaticallyImplyLeading: false,
              expandedHeight: _headerExpandedHeight,
              collapsedHeight: _headerCollapsedHeight,
              toolbarHeight: _headerCollapsedHeight,
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: Builder(
                builder: (ctx) {
                  final settings = ctx
                      .dependOnInheritedWidgetOfExactType<
                        FlexibleSpaceBarSettings
                      >();
                  final minExtent =
                      settings?.minExtent ?? _headerCollapsedHeight;
                  final maxExtent =
                      settings?.maxExtent ?? _headerExpandedHeight;
                  final currentExtent = settings?.currentExtent ?? maxExtent;
                  final deltaExtent = maxExtent - minExtent;
                  final t = deltaExtent <= 0
                      ? 1.0
                      : ((currentExtent - minExtent) / deltaExtent).clamp(
                          0.0,
                          1.0,
                        );
                  return _buildCollapsibleWelcome(t, theme, isDark);
                },
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Material(
                  color: theme.colorScheme.surface,
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    tabs: [
                      _buildTabLabel('루틴', routineCount),
                      _buildTabLabel('오늘', todayCount),
                      _buildTabLabel('예정', upcomingCount),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoutineTab(theme, isDark),
          _buildTodayTab(theme, isDark),
          _buildUpcomingTab(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildTabLabel(String label, int count) {
    return Tab(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoutineTab(ThemeData theme, bool isDark) {
    if (_activeRoutines.isEmpty) {
      return _buildTabEmpty(
        theme,
        pageKey: 'routine',
        icon: Icons.loop,
        title: '오늘 루틴 없음',
        subtitle: '+ 버튼으로 루틴을 추가해보세요',
      );
    }
    return _buildTabScrollView(
      pageKey: 'routine',
      children: [
        ..._sortedRoutines.map((routine) {
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
        const SizedBox(height: 16),
        _buildQuoteSection(theme, isDark),
      ],
    );
  }

  Widget _buildTodayTab(ThemeData theme, bool isDark) {
    if (_todayTasks.isEmpty) {
      return _buildTabEmpty(
        theme,
        pageKey: 'today',
        icon: Icons.assignment_outlined,
        title: '오늘 할 일 없음',
        subtitle: '+ 버튼으로 할 일을 추가해보세요',
      );
    }
    return _buildTabScrollView(
      pageKey: 'today',
      children: [
        ..._todayTasks.map((task) {
          final category = _getCategoryFor(task.categoryId);
          final isOverdue =
              !task.isCompleted && task.targetDate.compareTo(_today) < 0;
          final overdueDays = isOverdue
              ? DateTime.now()
                    .difference(DateTime.parse(task.targetDate))
                    .inDays
              : 0;
          return _buildTaskCard(
            task: task,
            category: category,
            overdueDays: overdueDays,
            isDark: isDark,
            theme: theme,
          );
        }),
        const SizedBox(height: 16),
        _buildQuoteSection(theme, isDark),
      ],
    );
  }

  Widget _buildUpcomingTab(ThemeData theme, bool isDark) {
    if (_upcomingTasks.isEmpty) {
      return _buildTabEmpty(
        theme,
        pageKey: 'upcoming',
        icon: Icons.event_outlined,
        title: '예정된 할 일 없음',
        subtitle: '미래 날짜로 할 일을 추가하면 여기에 표시돼요',
      );
    }
    return _buildTabScrollView(
      pageKey: 'upcoming',
      children: [
        ..._upcomingTasks.map((task) {
          final category = _getCategoryFor(task.categoryId);
          return _buildUpcomingTaskCard(
            task: task,
            category: category,
            isDark: isDark,
            theme: theme,
          );
        }),
        const SizedBox(height: 16),
        _buildQuoteSection(theme, isDark),
      ],
    );
  }

  Widget _buildTabScrollView({
    required String pageKey,
    required List<Widget> children,
  }) {
    return Builder(
      builder: (ctx) {
        return CustomScrollView(
          key: PageStorageKey<String>(pageKey),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverList(delegate: SliverChildListDelegate(children)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabEmpty(
    ThemeData theme, {
    required String pageKey,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Builder(
      builder: (ctx) {
        return CustomScrollView(
          key: PageStorageKey<String>('empty-$pageKey'),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 56,
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCollapsibleWelcome(double t, ThemeData theme, bool isDark) {
    final expandedOpacity = t.clamp(0.0, 1.0);
    final compactOpacity = (1 - t).clamp(0.0, 1.0);

    return ClipRect(
      child: Stack(
        children: [
          // Expanded layout (fades out on scroll)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: expandedOpacity < 0.5,
              child: Opacity(
                opacity: expandedOpacity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: _expandedWelcomeLayout(theme, isDark),
                ),
              ),
            ),
          ),
          // Compact layout (fades in on scroll), anchored to top (toolbar area, above TabBar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: compactOpacity < 0.5,
              child: Opacity(
                opacity: compactOpacity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
                  child: _compactWelcomeLayout(theme, isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expandedWelcomeLayout(ThemeData theme, bool isDark) {
    final remaining = _totalCount - _completedCount;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        DailyProgressRing(
          completed: _completedCount,
          total: _totalCount,
          size: 100,
        ),
      ],
    );
  }

  Widget _compactWelcomeLayout(ThemeData theme, bool isDark) {
    final percent = _totalCount == 0
        ? 0
        : (_completedCount / _totalCount * 100).round();
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Today's ",
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextSpan(
                    text: 'Progress',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_totalCount > 0) ...[
            SizedBox(
              width: 36,
              height: 36,
              child: DailyProgressRing(
                completed: _completedCount,
                total: _totalCount,
                size: 36,
                compact: true,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$_completedCount/$_totalCount · $percent%',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
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
        : (theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _editRoutine(routine),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _toggleRoutine(routine.id),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDone
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: isDone
                          ? null
                          : Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              width: 2,
                            ),
                    ),
                    child: isDone
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: theme.colorScheme.onPrimary,
                          )
                        : null,
                  ),
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
                              color: AppTheme.warning,
                              size: 13,
                            ),
                            Text(
                              ' $streak일 연속',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.warning,
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
    final cardColor =
        (theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest);
    final iconBg = category != null
        ? parseHexColor(category.color).withValues(alpha: 0.1)
        : theme.colorScheme.secondaryContainer;
    final iconColor = category != null
        ? parseHexColor(category.color)
        : theme.colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _editTask(task),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                      task.isCompleted
                          ? Icons.check
                          : Icons.assignment_outlined,
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
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
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
                                Text(
                                  ' • ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              if (task.subtasks.isNotEmpty)
                                Text(
                                  '${_completedSubtaskCount(task)}/${task.subtasks.length} 세부 항목',
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
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _toggleTask(task.id),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
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
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                  width: 2,
                                ),
                        ),
                        child: task.isCompleted
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: theme.colorScheme.onPrimary,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              if (task.subtasks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: task.subtasks.asMap().entries.map((entry) {
                      final i = entry.key;
                      final title = entry.value;
                      final done = task.isSubtaskCompleted(i);
                      return InkWell(
                        onTap: () => _toggleSubtask(task.id, i),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                done
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                size: 18,
                                color: done
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  title,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: done
                                        ? theme.colorScheme.onSurfaceVariant
                                        : theme.colorScheme.onSurface,
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _completedSubtaskCount(AdditionalTask task) {
    var count = 0;
    for (int i = 0; i < task.subtasks.length; i++) {
      if (task.isSubtaskCompleted(i)) count++;
    }
    return count;
  }

  Widget _buildUpcomingTaskCard({
    required AdditionalTask task,
    required Category? category,
    required bool isDark,
    required ThemeData theme,
  }) {
    final cardColor =
        (theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest);
    final iconBg = category != null
        ? parseHexColor(category.color).withValues(alpha: 0.1)
        : theme.colorScheme.secondaryContainer;
    final iconColor = category != null
        ? parseHexColor(category.color)
        : theme.colorScheme.secondary;

    final dt = DateTime.parse(task.targetDate);
    final weekday = ['월', '화', '수', '목', '금', '토', '일'][dt.weekday - 1];
    final dateLabel = '${dt.month}/${dt.day} ($weekday)';
    final daysLeft = dt.difference(DateTime.parse(_today)).inDays;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _editTask(task),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_outlined,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (task.subtasks.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${task.subtasks.length}개 세부 항목',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          dateLabel,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      if (daysLeft > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'D-$daysLeft',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (task.subtasks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: task.subtasks.map((title) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_box_outline_blank,
                              size: 18,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
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
            DailyQuotes.forDate(DateTime.parse(_today)),
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
