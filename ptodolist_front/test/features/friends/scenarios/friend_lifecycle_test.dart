import 'dart:async';

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
}) =>
    UserProfile(
      uid: uid,
      nickname: nickname,
      friendCode: code,
      publicMode: PublicMode.friends,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
    registerFallbackValue(_profile());
  });

  testWidgets('친구 추가 → 수락 → 친구 목록 풀 사이클', (tester) async {
    final user = _MockUser();
    when(() => user.uid).thenReturn('me-uid');
    final friendsRepo = _MockFriendsRepo();
    final profileRepo = _MockProfileRepo();

    // 양쪽 사용자가 받은 요청 / 친구 목록을 시뮬레이션할 stream controller
    final incomingCtrl = StreamController<List<FriendRequest>>.broadcast();
    final friendsCtrl = StreamController<List<Friendship>>.broadcast();

    when(() => profileRepo.findUidByFriendCode('AAAA-BBBB'))
        .thenAnswer((_) async => 'friend-uid');
    when(() => profileRepo.get('friend-uid'))
        .thenAnswer((_) async => _profile(uid: 'friend-uid', nickname: '친구A'));

    when(() => friendsRepo.sendRequest(
          toUid: any(named: 'toUid'),
          fromProfile: any(named: 'fromProfile'),
        )).thenAnswer((_) async {});

    // accept 호출 시 incoming 비우고 friendships 에 새 entry 추가
    when(() => friendsRepo.accept(
          myUid: any(named: 'myUid'),
          fromUid: any(named: 'fromUid'),
        )).thenAnswer((inv) async {
      incomingCtrl.add(const []);
      friendsCtrl.add([
        Friendship(
          pairId: 'friend-uid_me-uid',
          members: const ['friend-uid', 'me-uid'],
          createdAt: DateTime(2026, 5, 4),
        ),
      ]);
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [
        friendsRepoProvider.overrideWithValue(friendsRepo),
        userProfileRepoProvider.overrideWithValue(profileRepo),
        authStateProvider.overrideWith((ref) => Stream<User?>.value(user)),
        myProfileProvider
            .overrideWith((ref) => Stream<UserProfile?>.value(_profile())),
        incomingRequestsProvider.overrideWith((ref) => incomingCtrl.stream),
        myFriendshipsProvider.overrideWith((ref) => friendsCtrl.stream),
      ],
      child: const MaterialApp(home: FriendsView()),
    ));

    // 초기 상태: 빈 incoming + 빈 friendships
    incomingCtrl.add(const []);
    friendsCtrl.add(const []);
    await tester.pumpAndSettle();

    expect(find.textContaining('아직 친구가 없어요'), findsOneWidget);
    expect(find.textContaining('내 친구 (0)'), findsOneWidget);

    // 1단계: 코드 입력 + 요청 전송
    await tester.enterText(find.byType(TextField), 'AAAA-BBBB');
    await tester.tap(find.text('요청'));
    await tester.pumpAndSettle();

    verify(() => friendsRepo.sendRequest(
          toUid: 'friend-uid',
          fromProfile: any(named: 'fromProfile'),
        )).called(1);
    expect(find.textContaining('요청을 보냈어요'), findsOneWidget);

    // 2단계: (시뮬레이션) 친구가 나에게 요청 보냄 → incoming 에 등장
    incomingCtrl.add([
      FriendRequest(
        fromUid: 'friend-uid',
        fromNickname: '친구A',
        fromCode: 'AAAA-BBBB',
        createdAt: DateTime(2026, 5, 4),
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('친구A'), findsOneWidget);
    expect(find.text('수락'), findsOneWidget);

    // 3단계: 수락 탭
    await tester.tap(find.text('수락'));
    await tester.pumpAndSettle();

    verify(() => friendsRepo.accept(myUid: 'me-uid', fromUid: 'friend-uid'))
        .called(1);
    expect(find.text('친구가 됐어요'), findsOneWidget);

    // 4단계: incoming 비워지고 friend 1명으로 갱신
    await tester.pumpAndSettle();
    expect(find.textContaining('내 친구 (1)'), findsOneWidget);
    // 닉네임 표시 (FutureBuilder)
    expect(find.text('친구A'), findsOneWidget);

    incomingCtrl.close();
    friendsCtrl.close();
  });
}
