import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:ptodolist/features/push/services/push_relay_client.dart';

class _MockHttp extends Mock implements http.Client {}

void main() {
  late _MockHttp httpClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://x'));
  });

  setUp(() {
    httpClient = _MockHttp();
    when(() => httpClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{"sent":1}', 200));
  });

  PushRelayClient makeClient({
    String baseUrl = 'https://relay.example.workers.dev',
    String? idToken = 'id-token-1',
  }) {
    return PushRelayClient(
      baseUrl: baseUrl,
      httpClient: httpClient,
      idTokenProvider: () async => idToken,
    );
  }

  test('notifyFriendRequest: 올바른 경로/헤더/바디로 POST 한다', () async {
    await makeClient().notifyFriendRequest(toUid: 'bob');

    final captured = verify(() => httpClient.post(
          captureAny(),
          headers: captureAny(named: 'headers'),
          body: captureAny(named: 'body'),
        )).captured;
    expect((captured[0] as Uri).toString(),
        'https://relay.example.workers.dev/notify/friend-request');
    expect((captured[1] as Map)['Authorization'], 'Bearer id-token-1');
    expect(jsonDecode(captured[2] as String), {'toUid': 'bob'});
  });

  test('notifyFriendAccepted: accepted 경로로 POST 한다', () async {
    await makeClient().notifyFriendAccepted(toUid: 'bob');

    final uri = verify(() => httpClient.post(captureAny(),
            headers: any(named: 'headers'), body: any(named: 'body')))
        .captured
        .single as Uri;
    expect(uri.path, '/notify/friend-accepted');
  });

  test('baseUrl 이 비어있으면(미설정) 호출하지 않는다', () async {
    await makeClient(baseUrl: '').notifyFriendRequest(toUid: 'bob');
    verifyNever(() => httpClient.post(any(),
        headers: any(named: 'headers'), body: any(named: 'body')));
  });

  test('ID 토큰이 없으면(비로그인) 호출하지 않는다', () async {
    await makeClient(idToken: null).notifyFriendRequest(toUid: 'bob');
    verifyNever(() => httpClient.post(any(),
        headers: any(named: 'headers'), body: any(named: 'body')));
  });

  test('네트워크 오류가 나도 throw 하지 않는다 (알림은 best-effort)', () async {
    when(() => httpClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')))
        .thenThrow(Exception('network down'));

    await expectLater(makeClient().notifyFriendRequest(toUid: 'bob'), completes);
  });

  test('4xx/5xx 응답도 throw 하지 않는다', () async {
    when(() => httpClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{"error":"x"}', 500));

    await expectLater(makeClient().notifyFriendRequest(toUid: 'bob'), completes);
  });
}
