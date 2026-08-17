import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ptodolist/features/push/services/push_token_service.dart';

/// Firebase Auth + Google Sign-In 래퍼.
/// 앱은 비로그인 상태에서도 로컬 기능이 모두 동작 — 로그인은 소셜(피드) 기능에만 필요.
class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final PushTokenService? _pushTokens;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    PushTokenService? pushTokens,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _pushTokens = pushTokens;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'cancelled',
        message: '로그인을 취소했어요',
      );
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    // 토큰 삭제는 인증이 살아있는 동안만 규칙을 통과하므로 로그아웃보다 먼저.
    await _pushTokens?.unregister();
    await Future.wait([
      _googleSignIn.signOut(),
      _auth.signOut(),
    ]);
  }
}
