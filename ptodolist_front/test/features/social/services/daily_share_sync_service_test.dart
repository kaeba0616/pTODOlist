import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';
import 'package:ptodolist/features/profile/repos/user_profile_repo.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/social/models/daily_share.dart';
import 'package:ptodolist/features/social/repos/daily_share_repo.dart';
import 'package:ptodolist/features/social/services/daily_share_sync_service.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockProfileRepo extends Mock implements UserProfileRepository {}

class _MockShareRepo extends Mock implements DailyShareRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(DailyShare(
      uid: '',
      nickname: '',
      date: '',
      completedCount: 0,
      totalCount: 0,
      rate: 0,
      routines: const [],
      updatedAt: DateTime(2026, 1, 1),
    ));
  });

  group('DailyShareSyncService.syncToday', () {
    late _MockAuth auth;
    late _MockUser user;
    late _MockProfileRepo profileRepo;
    late _MockShareRepo shareRepo;
    late DailyShareSyncService service;

    final today = DailyRecord(
      date: '2026-05-02',
      routineCompletions: const {'r1': true, 'r2': false},
    );
    final routines = [
      Routine(
        id: 'r1',
        title: '아침 운동',
        categoryId: 'c1',
        order: 0,
        createdAt: DateTime(2026, 1, 1),
      ),
      Routine(
        id: 'r2',
        title: '영어 공부',
        categoryId: 'c1',
        order: 1,
        createdAt: DateTime(2026, 1, 1),
      ),
    ];

    setUp(() {
      auth = _MockAuth();
      user = _MockUser();
      profileRepo = _MockProfileRepo();
      shareRepo = _MockShareRepo();
      service = DailyShareSyncService(
        auth: auth,
        profileRepo: profileRepo,
        shareRepo: shareRepo,
      );
      when(() => user.uid).thenReturn('uid-1');
    });

    test('비로그인 → SyncedSkipped(no-user)', () async {
      when(() => auth.currentUser).thenReturn(null);

      final result = await service.syncToday(
        record: today,
        activeRoutines: routines,
      );

      expect(result, isA<SyncedSkipped>());
      expect((result as SyncedSkipped).reason, 'no-user');
      verifyNever(() => shareRepo.upsert(any()));
    });

    test('프로필 없음 → SyncedSkipped(no-profile)', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => profileRepo.get('uid-1')).thenAnswer((_) async => null);

      final result = await service.syncToday(
        record: today,
        activeRoutines: routines,
      );

      expect(result, isA<SyncedSkipped>());
      expect((result as SyncedSkipped).reason, 'no-profile');
      verifyNever(() => shareRepo.upsert(any()));
    });

    test('publicMode off → SyncedDeleted, repo.delete 호출', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => profileRepo.get('uid-1')).thenAnswer(
        (_) async => UserProfile(
          uid: 'uid-1',
          nickname: 'me',
          friendCode: 'AAAA-BBBB',
          publicMode: PublicMode.off,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
      when(() => shareRepo.delete(any(), any())).thenAnswer((_) async {});

      final result = await service.syncToday(
        record: today,
        activeRoutines: routines,
      );

      expect(result, isA<SyncedDeleted>());
      verify(() => shareRepo.delete('uid-1', '2026-05-02')).called(1);
      verifyNever(() => shareRepo.upsert(any()));
    });

    test('publicMode friends → SyncedOk, 정확한 share 객체로 upsert', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => profileRepo.get('uid-1')).thenAnswer(
        (_) async => UserProfile(
          uid: 'uid-1',
          nickname: '하이디',
          friendCode: 'KX7B-29M3',
          publicMode: PublicMode.friends,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
      DailyShare? captured;
      when(() => shareRepo.upsert(any())).thenAnswer((inv) async {
        captured = inv.positionalArguments[0] as DailyShare;
      });

      final result = await service.syncToday(
        record: today,
        activeRoutines: routines,
      );

      expect(result, isA<SyncedOk>());
      expect((result as SyncedOk).docId, 'uid-1_2026-05-02');
      expect(captured, isNotNull);
      expect(captured!.uid, 'uid-1');
      expect(captured!.nickname, '하이디');
      expect(captured!.date, '2026-05-02');
      expect(captured!.completedCount, 1);
      expect(captured!.totalCount, 2);
      expect(captured!.rate, closeTo(0.5, 0.001));
      expect(captured!.routines.length, 2);
      expect(
        captured!.routines.map((r) => '${r.name}:${r.done}').toSet(),
        {'아침 운동:true', '영어 공부:false'},
      );
    });

    test('upsert 가 throw → SyncedFailed', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => profileRepo.get('uid-1')).thenAnswer(
        (_) async => UserProfile(
          uid: 'uid-1',
          nickname: 'me',
          friendCode: 'CCCC-DDDD',
          publicMode: PublicMode.friends,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
      final boom = Exception('PERMISSION_DENIED');
      when(() => shareRepo.upsert(any())).thenThrow(boom);

      final result = await service.syncToday(
        record: today,
        activeRoutines: routines,
      );

      expect(result, isA<SyncedFailed>());
      expect((result as SyncedFailed).error, boom);
    });
  });
}
