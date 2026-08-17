import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptodolist/features/auth/services/auth_service.dart';
import 'package:ptodolist/features/push/services/push_token_service.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockPushTokens extends Mock implements PushTokenService {}

void main() {
  test('signOut 은 로그아웃 전에 푸시 토큰을 정리한다 (인증 살아있을 때만 삭제 가능)', () async {
    final auth = _MockAuth();
    final google = _MockGoogleSignIn();
    final pushTokens = _MockPushTokens();
    final calls = <String>[];

    when(() => pushTokens.unregister()).thenAnswer((_) async {
      calls.add('unregister');
    });
    when(() => auth.signOut()).thenAnswer((_) async {
      calls.add('authSignOut');
    });
    when(() => google.signOut()).thenAnswer((_) async => null);

    final service = AuthService(
      auth: auth,
      googleSignIn: google,
      pushTokens: pushTokens,
    );

    await service.signOut();

    expect(calls.first, 'unregister',
        reason: 'Firestore 규칙상 로그아웃 후에는 토큰 문서를 지울 수 없다');
    expect(calls, contains('authSignOut'));
  });

  test('signOut 은 pushTokens 미주입(mock 모드)이어도 동작한다', () async {
    final auth = _MockAuth();
    final google = _MockGoogleSignIn();
    when(() => auth.signOut()).thenAnswer((_) async {});
    when(() => google.signOut()).thenAnswer((_) async => null);

    final service = AuthService(auth: auth, googleSignIn: google);

    await expectLater(service.signOut(), completes);
  });
}
