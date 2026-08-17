import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:ptodolist/features/push/repos/push_token_repo.dart';

/// 로그인 사용자의 FCM 토큰 수명주기 관리.
/// - 로그인 시: 알림 권한 요청 → 토큰 발급 → Firestore 저장
/// - 토큰 갱신 시: 자동 재저장
/// - 로그아웃 직전: 토큰 삭제 (인증이 살아있어야 규칙 통과)
class PushTokenService {
  final FirebaseMessaging _messaging;
  final PushTokenRepository _repo;
  final String platform;

  StreamSubscription<String>? _refreshSub;
  String? _uid;
  String? _currentToken;

  PushTokenService({
    required FirebaseMessaging messaging,
    required PushTokenRepository repo,
    required this.platform,
  })  : _messaging = messaging,
        _repo = repo;

  Future<void> registerForUser(String uid) async {
    _uid = uid;
    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    if (token != null) {
      _currentToken = token;
      await _repo.saveToken(uid: uid, token: token, platform: platform);
    }

    _refreshSub ??= _messaging.onTokenRefresh.listen((newToken) async {
      _currentToken = newToken;
      final uid = _uid;
      if (uid == null) return; // 로그아웃 상태 — 저장 안 함
      try {
        await _repo.saveToken(uid: uid, token: newToken, platform: platform);
      } catch (e) {
        debugPrint('[push] token refresh save failed: $e');
      }
    });
  }

  Future<void> unregister() async {
    final uid = _uid;
    final token = _currentToken;
    _uid = null;
    if (uid == null || token == null) return;
    try {
      await _repo.deleteToken(uid: uid, token: token);
    } catch (e) {
      // 오프라인 등 — 무효 토큰은 Functions 발송 실패 시점에 정리됨
      debugPrint('[push] token cleanup failed: $e');
    }
  }
}
