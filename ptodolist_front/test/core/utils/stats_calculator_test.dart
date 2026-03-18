import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/core/utils/stats_calculator.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';

void main() {
  final dateFmt = DateFormat('yyyy-MM-dd');
  final today = dateFmt.format(DateTime.now());
  final yesterday = dateFmt.format(
    DateTime.now().subtract(const Duration(days: 1)),
  );

  group('StatsCalculator.dailyStats', () {
    test('레코드가 있는 날의 달성률을 계산한다', () {
      final records = [
        DailyRecord(
          date: today,
          routineCompletions: {'r-1': true, 'r-2': false},
        ),
        DailyRecord(
          date: yesterday,
          routineCompletions: {'r-1': true, 'r-2': true},
        ),
      ];

      final stats = StatsCalculator.dailyStats(
        records: records,
        tasks: [],
        days: 2,
      );

      expect(stats.length, 2);
      expect(stats.last.rate, 0.5); // today: 1/2
      expect(stats.first.rate, 1.0); // yesterday: 2/2
    });

    test('레코드가 없는 날은 0%이다', () {
      final stats = StatsCalculator.dailyStats(records: [], tasks: [], days: 3);

      expect(stats.length, 3);
      expect(stats.every((s) => s.rate == 0.0), true);
    });

    test('할 일도 달성률에 포함된다', () {
      final records = [
        DailyRecord(date: today, routineCompletions: {'r-1': true}),
      ];
      final tasks = [
        AdditionalTask(
          id: 't-1',
          title: '할일',
          categoryId: 'c',
          createdAt: DateTime.now(),
          targetDate: today,
          isCompleted: true,
        ),
        AdditionalTask(
          id: 't-2',
          title: '할일2',
          categoryId: 'c',
          createdAt: DateTime.now(),
          targetDate: today,
          isCompleted: false,
        ),
      ];

      final stats = StatsCalculator.dailyStats(
        records: records,
        tasks: tasks,
        days: 1,
      );

      // 루틴 1/1 + 할일 1/2 = 2/3 ≈ 0.667
      expect(stats.first.rate, closeTo(0.667, 0.01));
    });
  });

  group('StatsCalculator.weeklyStats', () {
    test('주별 통계를 계산한다', () {
      final stats = StatsCalculator.weeklyStats(
        records: [],
        tasks: [],
        weeks: 4,
      );

      expect(stats.length, 4);
    });
  });

  group('StatsCalculator.monthlyStats', () {
    test('월별 통계를 계산한다', () {
      final stats = StatsCalculator.monthlyStats(
        records: [],
        tasks: [],
        months: 6,
      );

      expect(stats.length, 6);
    });
  });
}
