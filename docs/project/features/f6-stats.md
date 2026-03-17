# F6: 달성률 통계

**Feature ID**: F6
**예상 기간**: 5일
**상태**: `[status: todo]`
**의존성**: F5

---

## Step 1: UX Planning & Design
- [ ] 일별(7일)/주별(4주)/월별(6개월) 차트 화면 설계
- [ ] 카테고리별 분석 UI 설계
- [ ] 기간 선택 탭 인터랙션
- [ ] `docs/ux/features/stats-flow.md` 작성
- [ ] `docs/ux/features/stats-screens.md` 작성

## Step 2: Flutter Mock UI
- [ ] `lib/features/stats/views/stats_view.dart`
- [ ] `lib/features/stats/viewmodels/stats_viewmodel.dart`
- [ ] `lib/features/stats/widgets/completion_chart.dart` (fl_chart)
- [ ] `lib/features/stats/widgets/category_breakdown.dart`
- [ ] `lib/features/stats/widgets/period_selector.dart`

## Step 3: Local DB Design
- [ ] stats_cache 박스 (선택적, 성능 최적화 필요시)

## Step 4: Local Repository Integration
- [ ] StatsRepository - DailyRecord 집계 메서드
- [ ] 일별/주별/월별 달성률 계산 로직
- [ ] 카테고리별 분석 로직

## 완료 조건
- [ ] PRD AC-06-1 ~ AC-06-5 충족
