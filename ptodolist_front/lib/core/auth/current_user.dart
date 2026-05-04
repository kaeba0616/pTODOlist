/// 전역 로그인 상태 — repo 가 push-through 할 때 어떤 user 의 cloud 로
/// 보낼지 결정. authStateChanges listener 가 갱신.
/// (singleton 패턴이 싫지만, 4개 repo 가 navigation 마다 새로 생성되는
/// 현재 구조 + Hive box 공유 패턴 하에선 가장 단순한 해결책.)
class CurrentUser {
  static String? uid;
}
