import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptodolist/features/friends/views/friend_detail_view.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';
import 'package:ptodolist/features/profile/providers/profile_providers.dart';
import 'package:ptodolist/features/profile/repos/user_profile_repo.dart';
import 'package:ptodolist/features/social/models/daily_share.dart';
import 'package:ptodolist/features/social/providers/social_providers.dart';
import 'package:ptodolist/features/social/repos/daily_share_repo.dart';

class _MockShareRepo extends Mock implements DailyShareRepository {}

class _MockProfileRepo extends Mock implements UserProfileRepository {}

UserProfile _profile({String nickname = '친구A'}) => UserProfile(
      uid: 'friend-uid',
      nickname: nickname,
      friendCode: 'AAAA-BBBB',
      publicMode: PublicMode.friends,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

DailyShare _share({
  int completed = 2,
  int total = 4,
  List<DailyShareRoutine> routines = const [],
}) =>
    DailyShare(
      uid: 'friend-uid',
      nickname: '친구A',
      date: '2026-05-04',
      completedCount: completed,
      totalCount: total,
      rate: total == 0 ? 0 : completed / total,
      routines: routines,
      updatedAt: DateTime(2026, 5, 4, 14, 30),
    );

Widget _wrap({
  required _MockShareRepo shareRepo,
  required _MockProfileRepo profileRepo,
  String date = '2026-05-04',
}) {
  return ProviderScope(
    overrides: [
      dailyShareRepoProvider.overrideWithValue(shareRepo),
      userProfileRepoProvider.overrideWithValue(profileRepo),
    ],
    child: MaterialApp(
      home: FriendDetailView(friendUid: 'friend-uid', date: date),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  group('FriendDetailView 시나리오', () {
    late _MockShareRepo shareRepo;
    late _MockProfileRepo profileRepo;

    setUp(() {
      shareRepo = _MockShareRepo();
      profileRepo = _MockProfileRepo();
      when(() => profileRepo.get('friend-uid'))
          .thenAnswer((_) async => _profile());
    });

    testWidgets('share 없음 → 0% 카드만 표시 (헤더 + 진행률 바)', (tester) async {
      when(() => shareRepo.watchUserDate('friend-uid', '2026-05-04'))
          .thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(
          _wrap(shareRepo: shareRepo, profileRepo: profileRepo));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget); // 0%
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('share 있음 → 진행률 % + 완료/총 + 진행률 바', (tester) async {
      when(() => shareRepo.watchUserDate('friend-uid', '2026-05-04'))
          .thenAnswer((_) => Stream.value(_share(completed: 3, total: 4)));

      await tester.pumpWidget(
          _wrap(shareRepo: shareRepo, profileRepo: profileRepo));
      await tester.pumpAndSettle();

      // 75% (3/4)
      expect(find.text('75'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      expect(find.text('3/4'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Firebase 미초기화 (테스트 환경) 시 친구 루틴 fetch 실패 → 빈 안내',
        (tester) async {
      // 테스트 환경에서는 FirebaseFirestore.instance 가 throw → fetch 가
      // 빈 리스트 반환 → "친구가 등록한 루틴이 없어요" 표시
      when(() => shareRepo.watchUserDate('friend-uid', '2026-05-04'))
          .thenAnswer((_) => Stream.value(_share(
                completed: 1,
                total: 2,
                routines: const [
                  DailyShareRoutine(name: '아침 운동', done: true),
                  DailyShareRoutine(name: '영어 공부', done: false),
                ],
              )));

      await tester.pumpWidget(
          _wrap(shareRepo: shareRepo, profileRepo: profileRepo));
      await tester.pumpAndSettle();

      expect(find.textContaining('친구가 등록한 루틴이 없어요'), findsOneWidget);
    });

    testWidgets('AppBar 에 친구 닉네임 표시', (tester) async {
      when(() => shareRepo.watchUserDate('friend-uid', '2026-05-04'))
          .thenAnswer((_) => Stream.value(_share()));

      await tester.pumpWidget(
          _wrap(shareRepo: shareRepo, profileRepo: profileRepo));
      await tester.pumpAndSettle();

      // AppBar title 에 닉네임 표시 (FutureBuilder 라 settle 후)
      expect(find.text('친구A'), findsWidgets);
    });

    testWidgets('마지막 업데이트 시각 표시', (tester) async {
      when(() => shareRepo.watchUserDate('friend-uid', '2026-05-04'))
          .thenAnswer((_) => Stream.value(_share()));

      await tester.pumpWidget(
          _wrap(shareRepo: shareRepo, profileRepo: profileRepo));
      await tester.pumpAndSettle();

      // _share 의 updatedAt = 2026-05-04 14:30
      expect(find.textContaining('마지막 업데이트'), findsOneWidget);
      expect(find.textContaining('5/4 14:30'), findsOneWidget);
    });
  });
}
