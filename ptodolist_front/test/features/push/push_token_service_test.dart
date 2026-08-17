import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptodolist/features/push/repos/push_token_repo.dart';
import 'package:ptodolist/features/push/services/push_token_service.dart';

class _MockMessaging extends Mock implements FirebaseMessaging {}

class _MockRepo extends Mock implements PushTokenRepository {}

class _FakeSettings extends Fake implements NotificationSettings {}

void main() {
  late _MockMessaging messaging;
  late _MockRepo repo;
  late StreamController<String> refreshCtrl;
  late PushTokenService service;

  setUp(() {
    messaging = _MockMessaging();
    repo = _MockRepo();
    refreshCtrl = StreamController<String>.broadcast();

    when(() => messaging.requestPermission())
        .thenAnswer((_) async => _FakeSettings());
    when(() => messaging.getToken()).thenAnswer((_) async => 'tok-1');
    when(() => messaging.onTokenRefresh)
        .thenAnswer((_) => refreshCtrl.stream);
    when(() => repo.saveToken(
          uid: any(named: 'uid'),
          token: any(named: 'token'),
          platform: any(named: 'platform'),
        )).thenAnswer((_) async {});
    when(() => repo.deleteToken(
          uid: any(named: 'uid'),
          token: any(named: 'token'),
        )).thenAnswer((_) async {});

    service = PushTokenService(
      messaging: messaging,
      repo: repo,
      platform: 'android',
    );
  });

  tearDown(() => refreshCtrl.close());

  test('registerForUser: 권한 요청 후 현재 토큰을 저장한다', () async {
    await service.registerForUser('alice');

    verify(() => messaging.requestPermission()).called(1);
    verify(() => repo.saveToken(uid: 'alice', token: 'tok-1', platform: 'android'))
        .called(1);
  });

  test('토큰 갱신 이벤트가 오면 새 토큰을 저장한다', () async {
    await service.registerForUser('alice');

    refreshCtrl.add('tok-2');
    await Future<void>.delayed(Duration.zero);

    verify(() => repo.saveToken(uid: 'alice', token: 'tok-2', platform: 'android'))
        .called(1);
  });

  test('getToken 이 null 이면 저장하지 않고 넘어간다', () async {
    when(() => messaging.getToken()).thenAnswer((_) async => null);

    await service.registerForUser('alice');

    verifyNever(() => repo.saveToken(
          uid: any(named: 'uid'),
          token: any(named: 'token'),
          platform: any(named: 'platform'),
        ));
  });

  test('unregister: 현재 토큰을 삭제하고 이후 갱신 이벤트는 무시한다', () async {
    await service.registerForUser('alice');

    await service.unregister();

    verify(() => repo.deleteToken(uid: 'alice', token: 'tok-1')).called(1);

    refreshCtrl.add('tok-3');
    await Future<void>.delayed(Duration.zero);
    verifyNever(() => repo.saveToken(
          uid: any(named: 'uid'),
          token: 'tok-3',
          platform: any(named: 'platform'),
        ));
  });

  test('unregister: 토큰 삭제 실패(오프라인 등)해도 throw 하지 않는다', () async {
    await service.registerForUser('alice');
    when(() => repo.deleteToken(
          uid: any(named: 'uid'),
          token: any(named: 'token'),
        )).thenThrow(Exception('offline'));

    await expectLater(service.unregister(), completes);
  });
}
