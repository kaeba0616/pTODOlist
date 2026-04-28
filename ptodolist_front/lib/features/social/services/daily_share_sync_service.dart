import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';
import 'package:ptodolist/features/profile/repos/user_profile_repo.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/social/models/daily_share.dart';
import 'package:ptodolist/features/social/repos/daily_share_repo.dart';

/// sync 결과를 호출자에게 전달하는 sealed type.
/// debug 단계에서 SnackBar 로 사용자에게 무엇이 일어났는지 노출.
sealed class SyncResult {
  const SyncResult();
}

class SyncedOk extends SyncResult {
  final String docId;
  const SyncedOk(this.docId);
}

class SyncedSkipped extends SyncResult {
  final String reason;
  const SyncedSkipped(this.reason);
}

class SyncedDeleted extends SyncResult {
  const SyncedDeleted();
}

class SyncedFailed extends SyncResult {
  final Object error;
  final StackTrace stackTrace;
  const SyncedFailed(this.error, this.stackTrace);
}

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

  Future<SyncResult> syncToday({
    required DailyRecord record,
    required List<Routine> activeRoutines,
  }) async {
    try {
      final auth = _authOverride ?? FirebaseAuth.instance;
      final user = auth.currentUser;
      if (user == null) return const SyncedSkipped('no-user');

      final profileRepo = _profileRepoOverride ?? UserProfileRepository();
      final profile = await profileRepo.get(user.uid);
      if (profile == null) return const SyncedSkipped('no-profile');

      final repo = _repoOverride ?? DailyShareRepository();
      if (profile.publicMode == PublicMode.off) {
        await repo.delete(user.uid, record.date);
        return const SyncedDeleted();
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
      return SyncedOk(DailyShare.docId(user.uid, record.date));
    } catch (e, st) {
      debugPrint('DailyShareSync failed: $e\n$st');
      return SyncedFailed(e, st);
    }
  }
}
