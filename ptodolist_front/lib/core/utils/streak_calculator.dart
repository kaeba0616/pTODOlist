import 'package:ptodolist/features/home/models/daily_record.dart';

class StreakCalculator {
  /// 특정 루틴의 현재 연속 달성 일수를 계산한다.
  /// [activeDays]가 비어있으면 매일 활성으로 간주.
  static int currentStreak({
    required String routineId,
    required List<DailyRecord> records,
    required String today,
    List<int> activeDays = const [],
  }) {
    if (records.isEmpty) return 0;

    // records를 날짜 맵으로 변환
    final recordMap = {for (final r in records) r.date: r};

    int streak = 0;
    var current = DateTime.parse(today);

    for (int i = 0; i < 365; i++) {
      final dateStr =
          '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
      final weekday = current.weekday; // 1=월~7=일

      // 활성 요일이 아니면 건너뛰기
      if (activeDays.isNotEmpty && !activeDays.contains(weekday)) {
        current = current.subtract(const Duration(days: 1));
        continue;
      }

      final record = recordMap[dateStr];
      if (record == null) {
        // 기록 없음 → streak 끊김
        break;
      }

      final completed = record.routineCompletions[routineId];
      if (completed == true) {
        streak++;
      } else {
        // 미완료 → streak 끊김
        break;
      }

      current = current.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
