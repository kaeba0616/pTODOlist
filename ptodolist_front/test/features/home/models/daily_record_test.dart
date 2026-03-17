import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';

void main() {
  group('DailyRecord', () {
    test('생성된다', () {
      final record = DailyRecord(
        date: '2026-03-17',
        routineCompletions: {'r-1': false, 'r-2': true},
      );

      expect(record.date, '2026-03-17');
      expect(record.totalCount, 2);
      expect(record.completedCount, 1);
    });

    test('루틴 완료 여부를 확인한다', () {
      final record = DailyRecord(
        date: '2026-03-17',
        routineCompletions: {'r-1': false, 'r-2': true},
      );

      expect(record.isRoutineCompleted('r-1'), false);
      expect(record.isRoutineCompleted('r-2'), true);
      expect(record.isRoutineCompleted('r-99'), false);
    });

    test('루틴 완료를 토글한다', () {
      final record = DailyRecord(
        date: '2026-03-17',
        routineCompletions: {'r-1': false, 'r-2': true},
      );

      final toggled = record.toggleRoutine('r-1');
      expect(toggled.isRoutineCompleted('r-1'), true);
      expect(toggled.completedCount, 2);

      final toggledBack = toggled.toggleRoutine('r-1');
      expect(toggledBack.isRoutineCompleted('r-1'), false);
    });

    test('달성률을 계산한다', () {
      final record = DailyRecord(
        date: '2026-03-17',
        routineCompletions: {'r-1': true, 'r-2': true, 'r-3': false, 'r-4': false},
      );

      expect(record.completionRate, 0.5);
    });

    test('빈 레코드의 달성률은 0이다', () {
      const record = DailyRecord(
        date: '2026-03-17',
        routineCompletions: {},
      );

      expect(record.completionRate, 0.0);
    });
  });
}
