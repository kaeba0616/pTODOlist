# F7: 11시 스마트 알림

**Feature ID**: F7
**예상 기간**: 3일
**상태**: `[status: completed]`
**의존성**: F5

---

## Step 1: UX Planning & Design
- [ ] 알림 내용 포맷 ("아직 N개의 할 일이 남았어요!")
- [ ] 설정 화면 내 알림 토글 UI
- [ ] `docs/ux/features/notification-flow.md` 작성

## Step 2: Flutter Mock UI
- [ ] `lib/features/settings/widgets/notification_toggle.dart`

## Step 3: Local DB Design
- [ ] AppSettings에 notificationEnabled, notificationTime 필드

## Step 4: Local Repository Integration
- [ ] `lib/core/services/notification_service.dart`
- [ ] WorkManager 백그라운드 태스크 (22:55 스케줄)
- [ ] Hive isolate 재초기화 → DailyRecord 조회 → 알림 발송/무음

## 완료 조건
- [ ] PRD AC-07-1 ~ AC-07-5 충족
