import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/routine/models/routine.dart';

void main() {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final testRoutines = [
    Routine(
      id: 'r-1',
      title: '운동',
      categoryId: 'cat-1',
      createdAt: DateTime(2026, 1, 1),
    ),
    Routine(
      id: 'r-2',
      title: '공부',
      categoryId: 'cat-2',
      createdAt: DateTime(2026, 1, 1),
    ),
    Routine(
      id: 'r-3',
      title: '독서',
      categoryId: 'cat-2',
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  group('DailyRecordRepository (Mock)', () {
    late DailyRecordRepository repo;

    setUp(() {
      repo = DailyRecordRepository(useMock: true);
    });

    test('오늘 레코드가 없으면 새로 생성한다', () {
      final record = repo.getOrCreateToday(testRoutines);

      expect(record.date, today);
      expect(record.totalCount, 3);
      expect(record.completedCount, 0);
    });

    test('오늘 레코드가 이미 있으면 기존 것을 반환한다', () {
      final first = repo.getOrCreateToday(testRoutines);
      // r-1 완료 처리
      final updated = first.toggleRoutine('r-1');
      repo.save(updated);

      final second = repo.getOrCreateToday(testRoutines);
      expect(second.isRoutineCompleted('r-1'), true);
      expect(second.completedCount, 1);
    });

    test('루틴 완료를 토글한다', () {
      repo.getOrCreateToday(testRoutines);

      final updated = repo.toggleRoutineCompletion(today, 'r-1', testRoutines);
      expect(updated.isRoutineCompleted('r-1'), true);

      final toggled = repo.toggleRoutineCompletion(today, 'r-1', testRoutines);
      expect(toggled.isRoutineCompleted('r-1'), false);
    });

    test('날짜 범위로 레코드를 조회한다', () {
      repo.getOrCreateToday(testRoutines);

      final records = repo.getRecordsInRange('2020-01-01', '2030-12-31');
      expect(records.length, 1);
      expect(records.first.date, today);
    });

    test('오래된 레코드를 삭제한다', () {
      // 오늘 레코드 생성
      repo.getOrCreateToday(testRoutines);

      // 미래 기준으로 삭제하면 오늘 레코드가 삭제됨
      final deleted = repo.deleteOlderThan(
        DateTime.now().add(const Duration(days: 1)),
      );
      expect(deleted, 1);

      expect(repo.get(today), isNull);
    });

    test('삭제 기준 이후 레코드는 유지된다', () {
      repo.getOrCreateToday(testRoutines);

      // 과거 기준으로 삭제하면 오늘 레코드는 유지
      final deleted = repo.deleteOlderThan(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(deleted, 0);

      expect(repo.get(today), isNotNull);
    });
  });
}
