import 'package:ptodolist/features/home/models/daily_record.dart';

/// 캘린더 테스트용 mock DailyRecord 데이터 (최근 60일)
List<DailyRecord> generateMockRecords({DateTime? baseDate}) {
  final base = baseDate ?? DateTime.now();
  final records = <DailyRecord>[];
  final routineIds = ['r-1', 'r-2', 'r-3', 'r-4', 'r-5'];

  for (int i = 0; i < 60; i++) {
    final date = base.subtract(Duration(days: i));
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // 다양한 달성률 패턴 생성
    final completions = <String, bool>{};
    for (int j = 0; j < routineIds.length; j++) {
      // 패턴: 최근일수록 높은 달성률
      completions[routineIds[j]] = (i + j) % (1 + i ~/ 10) == 0;
    }

    records.add(DailyRecord(date: dateStr, routineCompletions: completions));
  }

  return records;
}
