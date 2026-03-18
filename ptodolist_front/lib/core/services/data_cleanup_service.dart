import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/settings/repos/settings_repo.dart';

class DataCleanupService {
  final DailyRecordRepository dailyRecordRepo;
  final SettingsRepository settingsRepo;

  DataCleanupService({
    required this.dailyRecordRepo,
    required this.settingsRepo,
  });

  /// 앱 실행 시 호출. 보관기간 초과 DailyRecord 삭제.
  /// 반환값: 삭제된 레코드 수
  int cleanup() {
    final settings = settingsRepo.getSettings();
    final months = settings.retentionMonths;

    // 무제한이면 삭제 안 함
    if (months <= 0) return 0;

    final cutoff = DateTime.now().subtract(Duration(days: months * 30));
    return dailyRecordRepo.deleteOlderThan(cutoff);
  }
}
