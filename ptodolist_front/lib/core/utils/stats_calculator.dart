import 'package:intl/intl.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';

class DayStat {
  final String date;
  final String label;
  final double rate; // 0.0 ~ 1.0

  const DayStat({required this.date, required this.label, required this.rate});
}

class CategoryStat {
  final String categoryId;
  final String name;
  final String color;
  final double rate;

  const CategoryStat({
    required this.categoryId,
    required this.name,
    required this.color,
    required this.rate,
  });
}

class StatsCalculator {
  static final _dateFmt = DateFormat('yyyy-MM-dd');
  static final _dayNames = ['월', '화', '수', '목', '금', '토', '일'];

  /// 최근 N일의 일별 달성률
  static List<DayStat> dailyStats({
    required List<DailyRecord> records,
    required List<AdditionalTask> tasks,
    int days = 7,
  }) {
    final now = DateTime.now();
    final recordMap = {for (final r in records) r.date: r};
    final tasksByDate = <String, List<AdditionalTask>>{};
    for (final t in tasks) {
      tasksByDate.putIfAbsent(t.targetDate, () => []).add(t);
    }

    final stats = <DayStat>[];
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _dateFmt.format(date);
      final dayLabel = _dayNames[date.weekday - 1];

      final record = recordMap[dateStr];
      final dayTasks = tasksByDate[dateStr] ?? [];

      final routineTotal = record?.totalCount ?? 0;
      final routineDone = record?.completedCount ?? 0;
      final taskTotal = dayTasks.length;
      final taskDone = dayTasks.where((t) => t.isCompleted).length;

      final total = routineTotal + taskTotal;
      final done = routineDone + taskDone;
      final rate = total == 0 ? 0.0 : done / total;

      stats.add(DayStat(date: dateStr, label: dayLabel, rate: rate));
    }
    return stats;
  }

  /// 최근 N주의 주별 평균 달성률
  static List<DayStat> weeklyStats({
    required List<DailyRecord> records,
    required List<AdditionalTask> tasks,
    int weeks = 4,
  }) {
    final daily = dailyStats(records: records, tasks: tasks, days: weeks * 7);
    final stats = <DayStat>[];

    for (int w = 0; w < weeks; w++) {
      final start = w * 7;
      final end = start + 7;
      final weekSlice = daily.sublist(
        start,
        end > daily.length ? daily.length : end,
      );
      // 기록 없는 날은 0% 로 간주해 해당 기간(보통 7일) 길이로 나눈다.
      // 예전엔 비어있는 날을 제외해서 하루만 체크해도 주간이 100% 로 보였음.
      final avg = weekSlice.isEmpty
          ? 0.0
          : weekSlice.fold(0.0, (sum, d) => sum + d.rate) / weekSlice.length;

      final label = w == 0
          ? '${weeks - w}주 전'
          : w == weeks - 1
          ? '이번 주'
          : '${weeks - w}주 전';
      stats.add(DayStat(date: '', label: label, rate: avg));
    }
    return stats;
  }

  /// 최근 N개월의 월별 평균 달성률
  static List<DayStat> monthlyStats({
    required List<DailyRecord> records,
    required List<AdditionalTask> tasks,
    int months = 6,
  }) {
    final recordMap = {for (final r in records) r.date: r};
    final tasksByDate = <String, List<AdditionalTask>>{};
    for (final t in tasks) {
      tasksByDate.putIfAbsent(t.targetDate, () => []).add(t);
    }

    final now = DateTime.now();
    final stats = <DayStat>[];

    for (int m = months - 1; m >= 0; m--) {
      final month = DateTime(now.year, now.month - m, 1);
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      final monthLabel = '${month.month}월';

      double totalRate = 0;
      int countedDays = 0;

      for (int d = 1; d <= daysInMonth; d++) {
        final date = DateTime(month.year, month.month, d);
        if (date.isAfter(now)) break;
        final dateStr = _dateFmt.format(date);

        final record = recordMap[dateStr];
        final dayTasks = tasksByDate[dateStr] ?? [];
        final total = (record?.totalCount ?? 0) + dayTasks.length;
        final done = (record?.completedCount ?? 0) +
            dayTasks.where((t) => t.isCompleted).length;
        // 기록 없거나 total=0 인 날도 "0% 달성"으로 집계해 분모 유지.
        // 월의 시작부터 오늘(또는 말일)까지 경과한 날 수로 평균.
        totalRate += total == 0 ? 0.0 : done / total;
        countedDays++;
      }

      final avg = countedDays == 0 ? 0.0 : totalRate / countedDays;
      stats.add(DayStat(date: '', label: monthLabel, rate: avg));
    }
    return stats;
  }
}
