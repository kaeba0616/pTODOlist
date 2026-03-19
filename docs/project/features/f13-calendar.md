# F13: 캘린더 뷰 (달력)

- **Feature ID**: F13
- **예상 기간**: 3~4일
- **상태**: `[status: in-progress]`
- **의존성**: Phase 4 완료

## 개요

월별 캘린더에서 날짜별 달성률을 색상 강도로 표시 (GitHub 잔디 스타일).
날짜 탭 시 해당 일의 루틴/할일 상세 바텀시트 표시.
하단 네비게이션 4번째 탭으로 배치.

---

## Step 1: UX Planning & Design

- [x] `docs/ux/features/calendar-flow.md` 사용자 여정
- [x] `docs/ux/features/calendar-screens.md` 화면 구조

### 화면 구성
1. **월별 캘린더 뷰** (메인 탭 화면)
   - 월/년 헤더 + 좌우 네비게이션
   - 7열 그리드 (월~일)
   - 날짜 셀: 달성률에 따른 색상 강도
   - 오늘 날짜 강조 (테두리)
   - 스트릭 배너 (현재 연속 달성일)

2. **일별 상세 바텀시트** (날짜 탭 시)
   - 날짜 + 달성 요약 (X/Y 완료, Z%)
   - 루틴 목록 (완료/미완료 상태)
   - 할 일 목록 (완료/미완료 상태)
   - 읽기 전용

---

## Step 2: Flutter Mock UI

### 새로 생성할 파일
- `ptodolist_front/lib/features/calendar/views/calendar_view.dart`
- `ptodolist_front/lib/features/calendar/widgets/calendar_grid.dart`
- `ptodolist_front/lib/features/calendar/widgets/day_cell.dart`
- `ptodolist_front/lib/features/calendar/widgets/day_detail_sheet.dart`
- `ptodolist_front/lib/features/calendar/widgets/streak_banner.dart`
- `ptodolist_front/lib/features/calendar/mocks/calendar_mock.dart`

### 색상 매핑
- 0%: `surfaceContainerHighest` (빈 셀)
- 1~25%: `primaryContainer` 연하게
- 26~50%: `primaryContainer`
- 51~75%: `primary` 60% opacity
- 76~100%: `primary` 100%

### 테스트
- [x] DayCell 위젯 테스트 (색상 매핑)
- [x] CalendarGrid 위젯 테스트 (날짜 그리드 렌더링)
- [x] CalendarView 위젯 테스트 (월 네비게이션)
- [x] DayDetailSheet 위젯 테스트

---

## Step 3: DB Design (Hive)

- 새로운 Hive Box 불필요 (기존 DailyRecord 활용)
- [x] `DailyRecordRepo`에 `getCompletionRatesForMonth(year, month)` 추가
- [x] Repository 테스트

---

## Step 4: Integration

- [ ] Mock → Real Repository 전환
- [ ] `app_router.dart`에 4번째 탭 추가
- [ ] 통합 테스트

### 수정할 기존 파일
- `ptodolist_front/lib/core/router/app_router.dart` - 4번째 탭 추가
- `ptodolist_front/lib/features/home/repos/daily_record_repo.dart` - 월별 조회 메서드

### 재사용할 기존 코드
- `core/utils/streak_calculator.dart` - 스트릭 계산
- `core/utils/stats_calculator.dart` - 통계 계산 패턴 참고
- `features/stats/views/stats_view.dart` - 다중 Repository 소비 패턴
- `features/home/models/daily_record.dart` - `completionRate` 헬퍼

---

## 완료 조건

- [ ] 전체 테스트 통과
- [ ] 4번째 하단 탭에서 월별 캘린더 표시
- [ ] 날짜 탭 시 상세 바텀시트 표시
- [ ] 월 이동 네비게이션 동작
- [ ] 스트릭 배너 표시
- [ ] 사용자 검토 및 승인
