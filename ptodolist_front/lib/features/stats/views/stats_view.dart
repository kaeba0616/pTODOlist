import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/core/utils/stats_calculator.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';
import 'package:ptodolist/features/stats/widgets/completion_chart.dart';
import 'package:ptodolist/features/stats/widgets/category_breakdown.dart';

enum StatsPeriod { daily, weekly, monthly }

class StatsView extends StatefulWidget {
  final DailyRecordRepository? dailyRecordRepo;
  final RoutineRepository? routineRepo;
  final TaskRepository? taskRepo;
  final CategoryRepository? categoryRepo;

  const StatsView({
    super.key,
    this.dailyRecordRepo,
    this.routineRepo,
    this.taskRepo,
    this.categoryRepo,
  });

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  StatsPeriod _period = StatsPeriod.daily;
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  bool get _hasRepos =>
      widget.dailyRecordRepo != null &&
      widget.routineRepo != null &&
      widget.taskRepo != null &&
      widget.categoryRepo != null;

  List<DailyRecord> _getRecords(int days) {
    if (!_hasRepos) return [];
    final now = DateTime.now();
    final start = _dateFmt.format(now.subtract(Duration(days: days)));
    final end = _dateFmt.format(now);
    return widget.dailyRecordRepo!.getRecordsInRange(start, end);
  }

  List<DayStat> _getChartData() {
    if (!_hasRepos) return [];
    final tasks = widget.taskRepo!.getAll();
    switch (_period) {
      case StatsPeriod.daily:
        return StatsCalculator.dailyStats(
          records: _getRecords(7),
          tasks: tasks,
        );
      case StatsPeriod.weekly:
        return StatsCalculator.weeklyStats(
          records: _getRecords(28),
          tasks: tasks,
        );
      case StatsPeriod.monthly:
        return StatsCalculator.monthlyStats(
          records: _getRecords(180),
          tasks: tasks,
        );
    }
  }

  List<CategoryStat> _getCategoryStats() {
    if (!_hasRepos) return [];
    final categories = widget.categoryRepo!.getAll();
    final records = _getRecords(7);
    final routines = widget.routineRepo!.getAll();

    return categories
        .map((cat) {
          final catRoutineIds = routines
              .where((r) => r.categoryId == cat.id)
              .map((r) => r.id)
              .toSet();
          if (catRoutineIds.isEmpty) {
            return CategoryStat(
              categoryId: cat.id,
              name: cat.name,
              color: cat.color,
              rate: 0,
            );
          }

          int total = 0;
          int done = 0;
          for (final record in records) {
            for (final rid in catRoutineIds) {
              if (record.routineCompletions.containsKey(rid)) {
                total++;
                if (record.routineCompletions[rid]!) done++;
              }
            }
          }

          return CategoryStat(
            categoryId: cat.id,
            name: cat.name,
            color: cat.color,
            rate: total == 0 ? 0 : done / total,
          );
        })
        .where((s) => s.rate > 0 || true)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasRepos) {
      return Scaffold(
        appBar: AppBar(title: const Text('통계')),
        body: const Center(child: Text('달성률 통계')),
      );
    }

    final chartData = _getChartData();
    final categoryStats = _getCategoryStats();
    final hasData = chartData.any((d) => d.rate > 0);

    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
      body: !hasData
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('아직 데이터가 없어요'),
                  const SizedBox(height: 4),
                  Text(
                    '루틴을 체크하면 통계가 쌓이기 시작해요',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 기간 선택
                SegmentedButton<StatsPeriod>(
                  segments: const [
                    ButtonSegment(value: StatsPeriod.daily, label: Text('일별')),
                    ButtonSegment(value: StatsPeriod.weekly, label: Text('주별')),
                    ButtonSegment(
                      value: StatsPeriod.monthly,
                      label: Text('월별'),
                    ),
                  ],
                  selected: {_period},
                  onSelectionChanged: (set) =>
                      setState(() => _period = set.first),
                ),
                const SizedBox(height: 24),

                // 차트
                CompletionChart(stats: chartData),
                const SizedBox(height: 32),

                // 카테고리별 분석
                if (_period == StatsPeriod.daily)
                  CategoryBreakdown(stats: categoryStats),
              ],
            ),
    );
  }
}
