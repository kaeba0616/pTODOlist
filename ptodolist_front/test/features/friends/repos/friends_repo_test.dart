import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptodolist/features/friends/repos/friends_repo.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';
import 'package:ptodolist/features/push/services/push_relay_client.dart';

class _MockRelay extends Mock implements PushRelayClient {}

UserProfile _profile(String uid) => UserProfile(
      uid: uid,
      nickname: '닉네임-$uid',
      friendCode: 'CODE-$uid',
      publicMode: PublicMode.friends,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  late FakeFirebaseFirestore firestore;
  late _MockRelay relay;
  late FriendsRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    relay = _MockRelay();
    when(() => relay.notifyFriendRequest(toUid: any(named: 'toUid')))
        .thenAnswer((_) async {});
    when(() => relay.notifyFriendAccepted(toUid: any(named: 'toUid')))
        .thenAnswer((_) async {});
    repo = FriendsRepository(firestore: firestore, relay: relay);
  });

  test('sendRequest 는 받은 사람 수신함에 닉네임/코드를 비정규화해 저장한다', () async {
    await repo.sendRequest(toUid: 'bob', fromProfile: _profile('alice'));

    final doc = await firestore
        .collection('friendRequests')
        .doc('bob')
        .collection('incoming')
        .doc('alice')
        .get();
    expect(doc.exists, isTrue);
    expect(doc.data()!['fromUid'], 'alice');
    expect(doc.data()!['fromNickname'], '닉네임-alice');
    expect(doc.data()!['fromCode'], 'CODE-alice');
  });

  test('accept 는 acceptedBy(수락자)와 정렬된 members 로 friendship 을 만들고 요청을 지운다',
      () async {
    // bob 이 alice 의 요청을 수락하는 상황
    await firestore
        .collection('friendRequests')
        .doc('bob')
        .collection('incoming')
        .doc('alice')
        .set({'fromUid': 'alice'});

    await repo.accept(myUid: 'bob', fromUid: 'alice');

    final pair = await firestore.collection('friendships').doc('alice_bob').get();
    expect(pair.exists, isTrue);
    expect(pair.data()!['members'], ['alice', 'bob']);
    expect(pair.data()!['acceptedBy'], 'bob',
        reason: '보안 규칙이 acceptedBy == 수락자 본인을 요구한다');

    final req = await firestore
        .collection('friendRequests')
        .doc('bob')
        .collection('incoming')
        .doc('alice')
        .get();
    expect(req.exists, isFalse);
  });

  test('sendRequest 성공 후 릴레이에 friend-request 알림을 요청한다', () async {
    await repo.sendRequest(toUid: 'bob', fromProfile: _profile('alice'));

    verify(() => relay.notifyFriendRequest(toUid: 'bob')).called(1);
  });

  test('accept 성공 후 릴레이에 friend-accepted 알림을 요청한다 (대상=요청 보낸 쪽)', () async {
    await firestore
        .collection('friendRequests')
        .doc('bob')
        .collection('incoming')
        .doc('alice')
        .set({'fromUid': 'alice'});

    await repo.accept(myUid: 'bob', fromUid: 'alice');

    verify(() => relay.notifyFriendAccepted(toUid: 'alice')).called(1);
  });

  test('릴레이 미주입(mock 모드)이어도 sendRequest/accept 는 동작한다', () async {
    final bare = FriendsRepository(firestore: firestore);
    await bare.sendRequest(toUid: 'bob', fromProfile: _profile('alice'));
    await bare.accept(myUid: 'bob', fromUid: 'alice');

    final pair = await firestore.collection('friendships').doc('alice_bob').get();
    expect(pair.exists, isTrue);
  });

  test('removeFriend 는 friendship 문서를 삭제한다', () async {
    await firestore
        .collection('friendships')
        .doc('alice_bob')
        .set({'members': ['alice', 'bob']});

    await repo.removeFriend(myUid: 'bob', otherUid: 'alice');

    final pair = await firestore.collection('friendships').doc('alice_bob').get();
    expect(pair.exists, isFalse);
  });
}
