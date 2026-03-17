# F0: 앱 셸 & 네비게이션

**Feature ID**: F0
**예상 기간**: 3일
**상태**: `[status: completed]`

---

## Step 1: UX Planning & Design
- [ ] 바텀 탭 구조 정의 (오늘/통계/설정)
- [ ] 네비게이션 라우트 맵 작성
- [ ] `docs/ux/features/app-shell-flow.md` 작성
- [ ] `docs/ux/features/app-shell-screens.md` 작성

## Step 2: Flutter Mock UI
- [ ] `flutter create ptodolist_front` 실행
- [ ] pubspec.yaml 의존성 설정
- [ ] `lib/core/theme/app_theme.dart` - Material 3 테마
- [ ] `lib/core/router/app_router.dart` - go_router + ShellRoute
- [ ] `lib/main.dart` - ProviderScope + 라우터 연결
- [ ] 각 탭의 플레이스홀더 화면 생성
- [ ] Widget 테스트: 탭 전환 동작 확인

## Step 3: Local DB Design
- [ ] `lib/core/db/database_service.dart` - Hive 초기화
- [ ] AppSettings Hive TypeAdapter
- [ ] `docs/tech/db-schema.md` appSettings 박스 확정

## Step 4: Local Repository Integration
- [ ] AppSettingsRepository (Mock + Real)
- [ ] Hive 초기화 → 앱 시작 플로우 연동
- [ ] 통합 테스트: 앱 시작 시 Hive 초기화 성공

## 완료 조건
- [ ] 앱이 실행되고 3개 탭이 전환됨
- [ ] Material 3 테마가 적용됨
- [ ] Hive가 초기화되고 AppSettings 박스가 생성됨
