import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';
import 'package:ptodolist/features/profile/repos/user_profile_repo.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/social/models/daily_share.dart';
import 'package:ptodolist/features/social/repos/daily_share_repo.dart';

/// 로컬 DailyRecord → Firestore /dailyShares 동기화.
/// publicMode == off → 푸시 안 함 (덤프만). 로그인 안 됐으면 no-op.
/// Firebase 가 init 안 된 환경(예: 테스트) 에서도 안전하게 무시되도록 lazy init.
class DailyShareSyncService {
  DailyShareRepository? _repoOverride;
  UserProfileRepository? _profileRepoOverride;
  FirebaseAuth? _authOverride;

  DailyShareSyncService({
    DailyShareRepository? shareRepo,
    UserProfileRepository? profileRepo,
    FirebaseAuth? auth,
  })  : _repoOverride = shareRepo,
        _profileRepoOverride = profileRepo,
        _authOverride = auth;

  /// today 기준 한 번의 snapshot 동기화. 비동기, 실패는 모두 로그만.
  Future<void> syncToday({
    required DailyRecord record,
    required List<Routine> activeRoutines,
  }) async {
    try {
      final auth = _authOverride ?? FirebaseAuth.instance;
      final user = auth.currentUser;
      if (user == null) return;

      final profileRepo = _profileRepoOverride ?? UserProfileRepository();
      final profile = await profileRepo.get(user.uid);
      if (profile == null) return; // 프로필 미설정 → 동기화 안 함

      final repo = _repoOverride ?? DailyShareRepository();
      if (profile.publicMode == PublicMode.off) {
        // 비공개 모드: 기존 데이터 있으면 삭제 (오늘 분만)
        await repo.delete(user.uid, record.date);
        return;
      }

      final routinesById = {for (final r in activeRoutines) r.id: r};
      final routineSummary = record.routineCompletions.entries
          .map((e) {
            final routine = routinesById[e.key];
            if (routine == null) return null;
            return DailyShareRoutine(name: routine.title, done: e.value);
          })
          .whereType<DailyShareRoutine>()
          .toList();

      final share = DailyShare(
        uid: user.uid,
        nickname: profile.nickname,
        date: record.date,
        completedCount: record.completedCount,
        totalCount: record.totalCount,
        rate: record.completionRate,
        routines: routineSummary,
        updatedAt: DateTime.now(),
      );
      await repo.upsert(share);
    } catch (e, st) {
      debugPrint('DailyShareSync skipped: $e\n$st');
    }
  }
}
