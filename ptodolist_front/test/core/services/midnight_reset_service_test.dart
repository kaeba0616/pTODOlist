import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/core/services/midnight_reset_service.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';

void main() {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  group('MidnightResetService', () {
    late DailyRecordRepository dailyRecordRepo;
    late RoutineRepository routineRepo;
    late MidnightResetService service;

    setUp(() {
      dailyRecordRepo = DailyRecordRepository(useMock: true);
      routineRepo = RoutineRepository(useMock: true);
      service = MidnightResetService(
        dailyRecordRepo: dailyRecordRepo,
        routineRepo: routineRepo,
      );
    });

    test('getCurrentRecord()가 오늘의 DailyRecord를 반환한다', () {
      final record = service.getCurrentRecord();

      expect(record.date, today);
      expect(record.totalCount, 8); // mock routines 8개
      expect(record.completedCount, 0);
    });

    test('오늘 레코드가 없으면 자동 생성된다', () {
      expect(dailyRecordRepo.get(today), isNull);

      service.getCurrentRecord();

      expect(dailyRecordRepo.get(today), isNotNull);
    });

    test('이미 레코드가 있으면 기존 것을 반환한다', () {
      final first = service.getCurrentRecord();
      final updated = dailyRecordRepo.toggleRoutineCompletion(
          today, 'r-1', routineRepo.getActive());

      final second = service.getCurrentRecord();
      expect(second.isRoutineCompleted('r-1'), true);
    });
  });
}
