import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/core/theme/app_theme.dart';
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
        return StatsCalculator.dailyStats(records: _getRecords(7), tasks: tasks);
      case StatsPeriod.weekly:
        return StatsCalculator.weeklyStats(records: _getRecords(28), tasks: tasks);
      case StatsPeriod.monthly:
        return StatsCalculator.monthlyStats(records: _getRecords(180), tasks: tasks);
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
              categoryId: cat.id, name: cat.name, color: cat.color, rate: 0,
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
            categoryId: cat.id, name: cat.name, color: cat.color,
            rate: total == 0 ? 0 : done / total,
          );
        })
        .where((s) => s.rate > 0 || true)
        .toList();
  }

  double _getWeeklyRate() {
    final records = _getRecords(7);
    if (records.isEmpty) return 0;
    int total = 0;
    int done = 0;
    for (final r in records) {
      total += r.routineCompletions.length;
      done += r.completedCount;
    }
    return total == 0 ? 0 : done / total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_hasRepos) {
      return Scaffold(
        appBar: AppBar(title: const Text('통계')),
        body: const Center(child: Text('달성률 통계')),
      );
    }

    final chartData = _getChartData();
    final categoryStats = _getCategoryStats();
    final hasData = chartData.any((d) => d.rate > 0);
    final weeklyRate = _getWeeklyRate();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calendar_today, size: 20,
              color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('pTODOlist'),
          ],
        ),
      ),
      body: !hasData
          ? _buildEmptyState(theme)
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Title
                _buildTitle(theme),
                const SizedBox(height: 20),

                // Period selector
                SegmentedButton<StatsPeriod>(
                  segments: const [
                    ButtonSegment(value: StatsPeriod.daily, label: Text('일별')),
                    ButtonSegment(value: StatsPeriod.weekly, label: Text('주별')),
                    ButtonSegment(value: StatsPeriod.monthly, label: Text('월별')),
                  ],
                  selected: {_period},
                  onSelectionChanged: (set) =>
                      setState(() => _period = set.first),
                ),
                const SizedBox(height: 20),

                // Weekly progress card
                _buildWeeklyCard(theme, isDark, weeklyRate, chartData),
                const SizedBox(height: 16),

                // Insight card
                if (_period == StatsPeriod.daily) ...[
                  _buildInsightCard(theme, isDark),
                  const SizedBox(height: 16),
                ],

                // Category breakdown
                if (_period == StatsPeriod.daily && categoryStats.isNotEmpty) ...[
                  _buildCategorySection(theme, isDark, categoryStats),
                  const SizedBox(height: 16),
                ],

                // Bottom stats row
                _buildBottomStats(theme, isDark, weeklyRate),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.leaderboard, size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('아직 데이터가 없어요', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('루틴을 체크하면 통계가 쌓이기 시작해요',
              style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFORMANCE OVERVIEW',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.tertiary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '통계',
            style: GoogleFonts.manrope(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCard(ThemeData theme, bool isDark, double weeklyRate,
      List<DayStat> chartData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest),
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? null
            : Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('주간 달성률',
                      style: GoogleFonts.manrope(
                          fontSize: 20, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    '${(weeklyRate * 100).round()}% 완료',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(width: 8, height: 8,
                      decoration: BoxDecoration(
                          color: theme.colorScheme.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Container(width: 8, height: 8,
                      decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerHighest,
                          shape: BoxShape.circle)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: CompletionChart(stats: chartData),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(ThemeData theme, bool isDark) {
    final routines = widget.routineRepo?.getAll() ?? [];
    if (routines.isEmpty) return const SizedBox.shrink();

    // Find best routine
    final records = _getRecords(14);
    String bestName = routines.first.title;
    int bestCount = 0;
    for (final r in routines) {
      int count = 0;
      for (final rec in records) {
        if (rec.routineCompletions[r.id] == true) count++;
      }
      if (count > bestCount) {
        bestCount = count;
        bestName = r.title;
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18,
                      color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: 6),
                  Text(
                    'SMART INSIGHT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '가장 꾸준한 루틴은\n',
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    TextSpan(
                      text: bestName,
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimaryContainer,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '최근 2주간 $bestCount회 완료했어요.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.colorScheme.onPrimaryContainer
                      .withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          Positioned(
            right: -12,
            bottom: -12,
            child: Icon(
              Icons.flare,
              size: 100,
              color: theme.colorScheme.onPrimaryContainer
                  .withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
      ThemeData theme, bool isDark, List<CategoryStat> stats) {
    final cardColor = isDark ? theme.colorScheme.surface : AppTheme.surfaceContainerLow;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('카테고리별 달성률',
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('이번 주 루틴 완료율',
              style: GoogleFonts.inter(
                  fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          CategoryBreakdown(stats: stats),
        ],
      ),
    );
  }

  Widget _buildBottomStats(ThemeData theme, bool isDark, double weeklyRate) {
    final todayRecord = _getRecords(1);
    final todayRate = todayRecord.isNotEmpty
        ? (todayRecord.last.completedCount /
                (todayRecord.last.routineCompletions.length.clamp(1, 999)))
        : 0.0;
    final remaining = todayRecord.isNotEmpty
        ? todayRecord.last.routineCompletions.length -
            todayRecord.last.completedCount
        : 0;

    return Row(
      children: [
        // Focus Peak
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.psychology, size: 24,
                      color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Text('오늘 달성률',
                    style: GoogleFonts.manrope(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  '${(todayRate * 100).round()}%',
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Daily Goal Ring
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest),
              borderRadius: BorderRadius.circular(16),
              border: isDark
                  ? null
                  : Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: todayRate.clamp(0.0, 1.0),
                    backgroundColor: AppTheme.surfaceContainerHighest,
                    color: theme.colorScheme.primary,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  remaining > 0 ? '$remaining개 남음' : '완료!',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
