import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Cloudflare Worker 푸시 릴레이 호출 클라이언트.
/// 친구 요청/수락 직후 호출하면 Worker 가 사건 실존을 검증하고 FCM 을 발송한다.
/// 알림은 best-effort — 어떤 실패도 호출자에게 전파하지 않는다.
class PushRelayClient {
  /// 미설정('') 이면 비활성 (릴레이 미배포 상태에서도 앱 정상 동작).
  final String baseUrl;
  final http.Client _http;
  final Future<String?> Function() _idTokenProvider;

  PushRelayClient({
    required this.baseUrl,
    required http.Client httpClient,
    required Future<String?> Function() idTokenProvider,
  })  : _http = httpClient,
        _idTokenProvider = idTokenProvider;

  Future<void> notifyFriendRequest({required String toUid}) =>
      _post('/notify/friend-request', toUid);

  Future<void> notifyFriendAccepted({required String toUid}) =>
      _post('/notify/friend-accepted', toUid);

  Future<void> _post(String path, String toUid) async {
    if (baseUrl.isEmpty) return;
    try {
      final idToken = await _idTokenProvider();
      if (idToken == null) return;
      final res = await _http.post(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'toUid': toUid}),
      );
      if (res.statusCode != 200) {
        debugPrint('[push-relay] $path → ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('[push-relay] $path failed: $e');
    }
  }
}
