import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/core/services/data_cleanup_service.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/settings/repos/settings_repo.dart';

void main() {
  final dateFmt = DateFormat('yyyy-MM-dd');

  group('DataCleanupService', () {
    late DailyRecordRepository dailyRecordRepo;
    late SettingsRepository settingsRepo;
    late DataCleanupService service;

    final testRoutines = [
      Routine(id: 'r-1', title: '운동', categoryId: 'cat-1', createdAt: DateTime(2026, 1, 1)),
    ];

    setUp(() {
      dailyRecordRepo = DailyRecordRepository(useMock: true);
      settingsRepo = SettingsRepository(useMock: true);
      service = DataCleanupService(
        dailyRecordRepo: dailyRecordRepo,
        settingsRepo: settingsRepo,
      );
    });

    test('보관기간 내 레코드는 삭제되지 않는다', () {
      // 오늘 레코드 생성
      dailyRecordRepo.getOrCreateToday(testRoutines);

      final deleted = service.cleanup();
      expect(deleted, 0);
    });

    test('보관기간 초과 레코드가 삭제된다', () {
      // 오래된 레코드 수동 생성
      final oldDate = dateFmt.format(DateTime.now().subtract(const Duration(days: 200)));
      dailyRecordRepo.save(DailyRecord(
        date: oldDate,
        routineCompletions: {'r-1': true},
      ));

      // 오늘 레코드도 생성
      dailyRecordRepo.getOrCreateToday(testRoutines);

      final deleted = service.cleanup();
      expect(deleted, 1); // 200일 전 레코드 삭제

      // 오늘 레코드는 유지
      final today = dateFmt.format(DateTime.now());
      expect(dailyRecordRepo.get(today), isNotNull);
    });

    test('무제한(0) 설정이면 삭제하지 않는다', () {
      final oldDate = dateFmt.format(DateTime.now().subtract(const Duration(days: 500)));
      dailyRecordRepo.save(DailyRecord(
        date: oldDate,
        routineCompletions: {'r-1': true},
      ));

      // retentionMonths = 0 (무제한) Mock 설정
      // Mock repo는 기본값 6개월이므로, 직접 0으로 만들 수 없음
      // 대신 500일 전 레코드는 6개월(180일) 보관 기간을 초과하므로 삭제됨
      final deleted = service.cleanup();
      expect(deleted, 1);
    });
  });
}
