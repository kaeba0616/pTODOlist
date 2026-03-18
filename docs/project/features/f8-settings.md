# F8: 설정 & 데이터 관리

**Feature ID**: F8
**예상 기간**: 3일
**상태**: `[status: completed]`
**의존성**: F7

---

## Step 1: UX Planning & Design
- [ ] 설정 화면 레이아웃 (알림, 보관기간, 테마, 앱 정보)
- [ ] `docs/ux/features/settings-flow.md` 작성
- [ ] `docs/ux/features/settings-screens.md` 작성

## Step 2: Flutter Mock UI
- [ ] `lib/features/settings/views/settings_view.dart`
- [ ] `lib/features/settings/viewmodels/settings_viewmodel.dart`

## Step 3: Local DB Design
- [ ] AppSettings에 retentionMonths, themeMode 필드

## Step 4: Local Repository Integration
- [ ] SettingsRepository
- [ ] `lib/core/services/data_cleanup_service.dart`
- [ ] 앱 실행 시 보관기간 초과 DailyRecord 자동 삭제

## 완료 조건
- [ ] PRD AC-08-1 ~ AC-08-5 충족
