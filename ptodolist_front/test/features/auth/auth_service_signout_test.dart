import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ptodolist/features/auth/services/auth_service.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  test('signOut 은 Google 세션과 Firebase 세션을 모두 종료한다', () async {
    final auth = _MockAuth();
    final google = _MockGoogleSignIn();
    final calls = <String>[];

    when(() => auth.signOut()).thenAnswer((_) async {
      calls.add('authSignOut');
    });
    when(() => google.signOut()).thenAnswer((_) async {
      calls.add('googleSignOut');
      return null;
    });

    final service = AuthService(auth: auth, googleSignIn: google);

    await service.signOut();

    expect(calls, containsAll(['authSignOut', 'googleSignOut']));
  });
}
