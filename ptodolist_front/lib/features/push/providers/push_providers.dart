import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ptodolist/features/push/services/push_relay_client.dart';

/// 빌드 시 주입: flutter build ... --dart-define=PUSH_RELAY_URL=https://...workers.dev
/// 미설정이면 '' → 릴레이 비활성 (푸시 없이 정상 동작).
const pushRelayUrl = String.fromEnvironment('PUSH_RELAY_URL');

final pushRelayClientProvider = Provider<PushRelayClient>((ref) {
  return PushRelayClient(
    baseUrl: pushRelayUrl,
    httpClient: http.Client(),
    idTokenProvider: () async =>
        await FirebaseAuth.instance.currentUser?.getIdToken(),
  );
});
