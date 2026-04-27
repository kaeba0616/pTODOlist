import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptodolist/features/social/repos/daily_share_repo.dart';
import 'package:ptodolist/features/social/services/daily_share_sync_service.dart';

final dailyShareRepoProvider =
    Provider<DailyShareRepository>((ref) => DailyShareRepository());

final dailyShareSyncServiceProvider =
    Provider<DailyShareSyncService>((ref) => DailyShareSyncService());
