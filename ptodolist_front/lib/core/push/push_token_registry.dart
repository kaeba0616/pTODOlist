import 'package:ptodolist/features/push/services/push_token_service.dart';

/// main.dart 초기화 시 채워지는 전역 인스턴스.
/// USE_MOCK 모드나 Firebase 초기화 실패 시 null — 호출부는 null-safe 로 사용.
PushTokenService? pushTokenServiceInstance;
