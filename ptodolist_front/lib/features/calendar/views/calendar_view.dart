import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/core/sync/app_sync_tick.dart';
import 'package:ptodolist/features/calendar/widgets/calendar_grid.dart';
import 'package:ptodolist/features/calendar/widgets/day_detail_sheet.dart';
import 'package:ptodolist/features/calendar/widgets/streak_banner.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';
import 'package:ptodolist/core/utils/streak_calculator.dart';

class CalendarView extends StatefulWidget {
  final DailyRecordRepository dailyRecordRepo;
  final RoutineRepository routineRepo;
  final TaskRepository taskRepo;
  final CategoryRepository categoryRepo;

  const CalendarView({
    super.key,
    required this.dailyRecordRepo,
    required this.routineRepo,
    required this.taskRepo,
    required this.categoryRepo,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _displayedMonth;
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
    appSyncTick.addListener(_onCloudSync);
  }

  @override
  void dispose() {
    appSyncTick.removeListener(_onCloudSync);
    super.dispose();
  }

  void _onCloudSync() {
    if (mounted) setState(() {});
  }

  Map<String, double> _getCompletionRates() {
    return widget.dailyRecordRepo.getCompletionRatesForMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );
  }

  int _calculateOverallStreak() {
    final today = _dateFmt.format(DateTime.now());
    final records = widget.dailyRecordRepo.getRecordsInRange(
      _dateFmt.format(DateTime.now().subtract(const Duration(days: 365))),
      today,
    );
    if (records.isEmpty) return 0;

    // 전체 달성률 기반 스트릭: 해당 날 completionRate > 0이면 달성으로 간주
    int streak = 0;
    var current = DateTime.now();
    final recordMap = {for (final r in records) r.date: r};

    for (int i = 0; i < 365; i++) {
      final dateStr = _dateFmt.format(current);
      final record = recordMap[dateStr];
      if (record == null || record.completionRate == 0) break;
      streak++;
      current = current.subtract(const Duration(days: 1));
    }
    return streak;
  }

  void _showDayDetail(int day) {
    final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
    final dateStr = _dateFmt.format(date);
    final record = widget.dailyRecordRepo.get(dateStr);
    final routines = widget.routineRepo.getAllIncludingDeleted();
    final tasks = widget.taskRepo.getAll().where((t) => t.targetDate == dateStr).toList();
    final categories = widget.categoryRepo.getAll();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayDetailSheet(
        date: date,
        record: record,
        routines: routines,
        tasks: tasks,
        categories: categories,
      ),
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final completionRates = _getCompletionRates();
    final streak = _calculateOverallStreak();
    final hasData = completionRates.values.any((r) => r > 0);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _goToPreviousMonth,
            ),
            Text(
              '${_displayedMonth.year}년 ${_displayedMonth.month}월',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _goToNextMonth,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 스트릭 배너
            StreakBanner(streakDays: streak),

            // 캘린더 그리드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CalendarGrid(
                year: _displayedMonth.year,
                month: _displayedMonth.month,
                completionRates: completionRates,
                today: DateTime.now(),
                onDayTap: _showDayDetail,
              ),
            ),

            // 데이터 없음 안내
            if (!hasData) ...[
              const SizedBox(height: 32),
              Icon(Icons.calendar_month, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                '이 달에는 기록이 없습니다',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
