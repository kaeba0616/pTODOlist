# F5: 일일 기록 & 자정 리셋

**Feature ID**: F5
**예상 기간**: 4일
**상태**: `[status: completed]`
**의존성**: F4

---

## Step 1: UX Planning & Design
- [ ] DailyRecord 생성/초기화 로직 설계 (비UI, 인프라)
- [ ] 자정 초기화 3가지 시나리오 정의
- [ ] `docs/ux/features/daily-record-flow.md` 작성

## Step 2: Flutter Mock UI
- [ ] `lib/features/home/models/daily_record.dart` - freezed 모델
- [ ] `lib/features/home/mocks/daily_record_mock.dart` - 과거 30일 Mock
- [ ] Mock ViewModel에서 날짜 변경 감지 시뮬레이션
- [ ] Unit 테스트: DailyRecord 모델, completionRate 계산

## Step 3: Local DB Design
- [ ] DailyRecord Hive TypeAdapter (typeId: 3)
- [ ] `dailyRecords` 박스 등록 (키: yyyy-MM-dd)
- [ ] `docs/tech/db-schema.md` 확정

## Step 4: Local Repository Integration
- [ ] DailyRecordRepository
  - [ ] `getOrCreateToday()` - 오늘 레코드 존재 여부 확인/생성
  - [ ] `toggleRoutineCompletion(routineId)` - 완료 토글
  - [ ] `getRecordsInRange(start, end)` - 통계용 범위 조회
- [ ] `lib/core/services/midnight_reset_service.dart`
  - [ ] 시나리오 A: 포그라운드 자정 타이머 (60초 주기)
  - [ ] 시나리오 B: 백그라운드 복귀 시 AppLifecycleState 체크
  - [ ] 시나리오 C: 앱 시작 시 getOrCreateToday()
- [ ] Unit 테스트: getOrCreateToday, 날짜 변경 감지
- [ ] 통합 테스트: 모의 날짜 변경 → 새 DailyRecord 생성

## 완료 조건
- [ ] 앱 실행 시 오늘의 DailyRecord 자동 생성
- [ ] 체크박스 토글이 DailyRecord에 반영
- [ ] 포그라운드 자정 넘김 시 초기화
- [ ] 백그라운드 복귀 시 날짜 변경 감지
- [ ] 이전 기록 보존 (삭제 없음)
- [ ] PRD AC-05-1 ~ AC-05-6 충족
