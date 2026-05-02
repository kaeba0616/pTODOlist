import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptodolist/features/auth/providers/auth_providers.dart';
import 'package:ptodolist/features/friends/models/friendship.dart';
import 'package:ptodolist/features/friends/providers/friends_providers.dart';
import 'package:ptodolist/features/friends/repos/friends_repo.dart';
import 'package:ptodolist/features/friends/views/friends_view.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';
import 'package:ptodolist/features/profile/providers/profile_providers.dart';
import 'package:ptodolist/features/profile/repos/user_profile_repo.dart';

class _MockUser extends Mock implements User {}

class _MockFriendsRepo extends Mock implements FriendsRepository {}

class _MockProfileRepo extends Mock implements UserProfileRepository {}

UserProfile _profile({
  String uid = 'me-uid',
  String nickname = '나',
  String code = 'KX7B-29M3',
  PublicMode mode = PublicMode.friends,
}) =>
    UserProfile(
      uid: uid,
      nickname: nickname,
      friendCode: code,
      publicMode: mode,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Widget _wrap({
  required _MockFriendsRepo friendsRepo,
  required _MockProfileRepo profileRepo,
  User? user,
  UserProfile? myProfile,
  List<FriendRequest> incoming = const [],
  List<Friendship> friendships = const [],
}) {
  return ProviderScope(
    overrides: [
      friendsRepoProvider.overrideWithValue(friendsRepo),
      userProfileRepoProvider.overrideWithValue(profileRepo),
      authStateProvider
          .overrideWith((ref) => Stream<User?>.value(user)),
      myProfileProvider
          .overrideWith((ref) => Stream<UserProfile?>.value(myProfile)),
      incomingRequestsProvider
          .overrideWith((ref) => Stream<List<FriendRequest>>.value(incoming)),
      myFriendshipsProvider
          .overrideWith((ref) => Stream<List<Friendship>>.value(friendships)),
    ],
    child: const MaterialApp(home: FriendsView()),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
    registerFallbackValue(_profile());
  });

  group('FriendsView 비로그인 시', () {
    testWidgets('"로그인 필요" 안내가 표시됨', (tester) async {
      await tester.pumpWidget(_wrap(
        friendsRepo: _MockFriendsRepo(),
        profileRepo: _MockProfileRepo(),
        user: null,
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('로그인'), findsWidgets);
    });
  });

  group('FriendsView 로그인 + 프로필 있음', () {
    late _MockUser user;
    late _MockFriendsRepo friendsRepo;
    late _MockProfileRepo profileRepo;

    setUp(() {
      user = _MockUser();
      when(() => user.uid).thenReturn('me-uid');
      friendsRepo = _MockFriendsRepo();
      profileRepo = _MockProfileRepo();
    });

    testWidgets('내 친구 코드가 표시됨', (tester) async {
      await tester.pumpWidget(_wrap(
        friendsRepo: friendsRepo,
        profileRepo: profileRepo,
        user: user,
        myProfile: _profile(code: 'KX7B-29M3'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('KX7B-29M3'), findsOneWidget);
      expect(find.text('MY FRIEND CODE'), findsOneWidget);
    });

    testWidgets('받은 요청 1건이 닉네임/코드와 함께 표시', (tester) async {
      final req = FriendRequest(
        fromUid: 'friend-uid',
        fromNickname: '친구A',
        fromCode: 'AAAA-BBBB',
        createdAt: DateTime(2026, 5, 2),
      );
      await tester.pumpWidget(_wrap(
        friendsRepo: friendsRepo,
        profileRepo: profileRepo,
        user: user,
        myProfile: _profile(),
        incoming: [req],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('받은 요청 (1)'), findsOneWidget);
      expect(find.text('친구A'), findsOneWidget);
      expect(find.text('코드 AAAA-BBBB'), findsOneWidget);
      expect(find.text('수락'), findsOneWidget);
      expect(find.text('거절'), findsOneWidget);
    });

    testWidgets('수락 버튼 탭 시 friendsRepo.accept 호출', (tester) async {
      final req = FriendRequest(
        fromUid: 'friend-uid',
        fromNickname: '친구A',
        fromCode: 'AAAA-BBBB',
        createdAt: DateTime(2026, 5, 2),
      );
      when(() => friendsRepo.accept(
            myUid: any(named: 'myUid'),
            fromUid: any(named: 'fromUid'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(_wrap(
        friendsRepo: friendsRepo,
        profileRepo: profileRepo,
        user: user,
        myProfile: _profile(),
        incoming: [req],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('수락'));
      await tester.pumpAndSettle();

      verify(() =>
              friendsRepo.accept(myUid: 'me-uid', fromUid: 'friend-uid'))
          .called(1);
      expect(find.text('친구가 됐어요'), findsOneWidget);
    });

    testWidgets('거절 버튼 탭 시 friendsRepo.decline 호출', (tester) async {
      final req = FriendRequest(
        fromUid: 'friend-uid',
        fromNickname: '친구A',
        fromCode: 'AAAA-BBBB',
        createdAt: DateTime(2026, 5, 2),
      );
      when(() => friendsRepo.decline(
            myUid: any(named: 'myUid'),
            fromUid: any(named: 'fromUid'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(_wrap(
        friendsRepo: friendsRepo,
        profileRepo: profileRepo,
        user: user,
        myProfile: _profile(),
        incoming: [req],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('거절'));
      await tester.pumpAndSettle();

      verify(() =>
              friendsRepo.decline(myUid: 'me-uid', fromUid: 'friend-uid'))
          .called(1);
    });

    testWidgets('친구 0명일 때 빈 상태 안내', (tester) async {
      await tester.pumpWidget(_wrap(
        friendsRepo: friendsRepo,
        profileRepo: profileRepo,
        user: user,
        myProfile: _profile(),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('아직 친구가 없어요'), findsOneWidget);
      expect(find.textContaining('내 친구 (0)'), findsOneWidget);
    });

    testWidgets('친구 1명일 때 목록에 닉네임 표시', (tester) async {
      final friendship = Friendship(
        pairId: 'friend-uid_me-uid',
        members: const ['friend-uid', 'me-uid'],
        createdAt: DateTime(2026, 4, 1),
      );
      when(() => profileRepo.get('friend-uid')).thenAnswer(
        (_) async => _profile(uid: 'friend-uid', nickname: '친구B'),
      );
      await tester.pumpWidget(_wrap(
        friendsRepo: friendsRepo,
        profileRepo: profileRepo,
        user: user,
        myProfile: _profile(),
        friendships: [friendship],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('내 친구 (1)'), findsOneWidget);
      expect(find.text('친구B'), findsOneWidget);
    });
  });

  group('FriendsView 친구 추가 플로우', () {
    late _MockUser user;
    late _MockFriendsRepo friendsRepo;
    late _MockProfileRepo profileRepo;

    setUp(() {
      user = _MockUser();
      when(() => user.uid).thenReturn('me-uid');
      friendsRepo = _MockFriendsRepo();
      profileRepo = _MockProfileRepo();
    });

    testWidgets('잘못된 형식 코드 → 유효성 에러 SnackBar', (tester) async {
      await tester.pumpWidget(_wrap(
        friendsRepo: friendsRepo,
        profileRepo: profileRepo,
        user: user,
        myProfile: _profile(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'short');
      await tester.tap(find.text('요청'));
      await tester.pumpAndSettle();

      expect(find.textContaining('유효한 8자 코드가 아니에요'), findsOneWidget);
      verifyNever(() => friendsRepo.sendRequest(
            toUid: any(named: 'toUid'),
            fromProfile: any(named: 'fromProfile'),
          ));
    });

    testWidgets('존재하지 않는 코드 → "찾을 수 없어요"', (tester) async {
      when(() => profileRepo.findUidByFriendCode(any()))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(_wrap(
        friendsRepo: friendsRepo,
        profileRepo: profileRepo,
        user: user,
        myProfile: _profile(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'AAAA-BBBB');
      await tester.tap(find.text('요청'));
      await tester.pumpAndSettle();

      expect(
          find.textContaining('해당 코드의 사용자를 찾을 수 없어요'), findsOneWidget);
    });

    testWidgets('유효한 코드 → friendsRepo.sendRequest 호출 + 성공 SnackBar',
        (tester) async {
      when(() => profileRepo.findUidByFriendCode(any()))
          .thenAnswer((_) async => 'friend-uid');
      when(() => friendsRepo.sendRequest(
            toUid: any(named: 'toUid'),
            fromProfile: any(named: 'fromProfile'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(_wrap(
        friendsRepo: friendsRepo,
        profileRepo: profileRepo,
        user: user,
        myProfile: _profile(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'AAAA-BBBB');
      await tester.tap(find.text('요청'));
      await tester.pumpAndSettle();

      verify(() => friendsRepo.sendRequest(
            toUid: 'friend-uid',
            fromProfile: any(named: 'fromProfile'),
          )).called(1);
      expect(find.textContaining('요청을 보냈어요'), findsOneWidget);
    });

    testWidgets('이미 친구인 코드 → "이미 친구예요"', (tester) async {
      when(() => profileRepo.findUidByFriendCode(any()))
          .thenAnswer((_) async => 'friend-uid');
      when(() => friendsRepo.sendRequest(
            toUid: any(named: 'toUid'),
            fromProfile: any(named: 'fromProfile'),
          )).thenThrow(StateError('already-friends'));

      await tester.pumpWidget(_wrap(
        friendsRepo: friendsRepo,
        profileRepo: profileRepo,
        user: user,
        myProfile: _profile(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'AAAA-BBBB');
      await tester.tap(find.text('요청'));
      await tester.pumpAndSettle();

      expect(find.textContaining('이미 친구예요'), findsOneWidget);
    });
  });
}
