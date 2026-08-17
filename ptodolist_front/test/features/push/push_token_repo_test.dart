import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/push/repos/push_token_repo.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late PushTokenRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = PushTokenRepository(firestore: firestore);
  });

  test('saveToken 은 users/{uid}/fcmTokens/{token} 문서를 만든다', () async {
    await repo.saveToken(uid: 'alice', token: 'tok-1', platform: 'android');

    final doc = await firestore
        .collection('users')
        .doc('alice')
        .collection('fcmTokens')
        .doc('tok-1')
        .get();
    expect(doc.exists, isTrue);
    expect(doc.data()!['platform'], 'android');
    expect(doc.data()!['updatedAt'], isNotNull);
  });

  test('같은 토큰 재저장은 문서 1개를 유지한다(멱등)', () async {
    await repo.saveToken(uid: 'alice', token: 'tok-1', platform: 'android');
    await repo.saveToken(uid: 'alice', token: 'tok-1', platform: 'android');

    final snap = await firestore
        .collection('users')
        .doc('alice')
        .collection('fcmTokens')
        .get();
    expect(snap.docs.length, 1);
  });

  test('deleteToken 은 해당 토큰 문서만 지운다', () async {
    await repo.saveToken(uid: 'alice', token: 'tok-1', platform: 'android');
    await repo.saveToken(uid: 'alice', token: 'tok-2', platform: 'android');

    await repo.deleteToken(uid: 'alice', token: 'tok-1');

    final snap = await firestore
        .collection('users')
        .doc('alice')
        .collection('fcmTokens')
        .get();
    expect(snap.docs.map((d) => d.id), ['tok-2']);
  });
}
