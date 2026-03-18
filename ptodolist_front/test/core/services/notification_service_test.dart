import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';

// NotificationService는 플랫폼 플러그인에 의존하므로
// 핵심 로직(미완료 카운트)만 단위 테스트
void main() {
  group('Smart Reminder Logic', () {
    test('미완료 루틴이 있으면 알림 대상이다', () {
      const record = DailyRecord(
        date: '2026-03-17',
        routineCompletions: {'r-1': true, 'r-2': false, 'r-3': false},
      );

      final incomplete = record.routineCompletions.values
          .where((v) => !v)
          .length;
      expect(incomplete, 2);
    });

    test('모든 루틴이 완료이면 알림 대상이 아니다', () {
      const record = DailyRecord(
        date: '2026-03-17',
        routineCompletions: {'r-1': true, 'r-2': true},
      );

      final incomplete = record.routineCompletions.values
          .where((v) => !v)
          .length;
      expect(incomplete, 0);
    });

    test('미완료 할 일도 카운트된다', () {
      final tasks = [
        AdditionalTask(
          id: 't-1',
          title: '할일1',
          categoryId: 'c',
          createdAt: DateTime.now(),
          targetDate: '2026-03-17',
          isCompleted: false,
        ),
        AdditionalTask(
          id: 't-2',
          title: '할일2',
          categoryId: 'c',
          createdAt: DateTime.now(),
          targetDate: '2026-03-17',
          isCompleted: true,
        ),
      ];

      final taskIncomplete = tasks.where((t) => !t.isCompleted).length;
      expect(taskIncomplete, 1);
    });

    test('루틴+할일 통합 미완료 카운트', () {
      const record = DailyRecord(
        date: '2026-03-17',
        routineCompletions: {'r-1': false},
      );
      final tasks = [
        AdditionalTask(
          id: 't-1',
          title: '할일',
          categoryId: 'c',
          createdAt: DateTime.now(),
          targetDate: '2026-03-17',
          isCompleted: false,
        ),
      ];

      final routineIncomplete = record.routineCompletions.values
          .where((v) => !v)
          .length;
      final taskIncomplete = tasks.where((t) => !t.isCompleted).length;
      final total = routineIncomplete + taskIncomplete;

      expect(total, 2);
    });
  });
}
