import 'package:cloud_firestore/cloud_firestore.dart';

/// FCM 토큰 저장소 — users/{uid}/fcmTokens/{token}
/// 문서 ID = 토큰 자체 (저장 멱등, 삭제가 단순해짐).
/// 읽기는 Cloud Functions(Admin SDK) 만 하므로 클라이언트 read 는 본인 전용.
class PushTokenRepository {
  final FirebaseFirestore _firestore;

  PushTokenRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tokens(String uid) =>
      _firestore.collection('users').doc(uid).collection('fcmTokens');

  Future<void> saveToken({
    required String uid,
    required String token,
    required String platform,
  }) {
    return _tokens(uid).doc(token).set({
      'platform': platform,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteToken({required String uid, required String token}) {
    return _tokens(uid).doc(token).delete();
  }
}
