# F4: 오늘 화면

**Feature ID**: F4
**예상 기간**: 4일
**상태**: `[status: completed]`
**의존성**: F2, F3

---

## Step 1: UX Planning & Design
- [ ] 홈 화면 레이아웃 (날짜, 프로그레스링, 루틴섹션, 할일섹션, FAB)
- [ ] 카테고리별 그룹핑 방식
- [ ] FAB → 바텀시트 (루틴/할일 선택) 인터랙션
- [ ] `docs/ux/features/home-flow.md` 작성
- [ ] `docs/ux/features/home-screens.md` 작성

## Step 2: Flutter Mock UI
- [ ] `lib/features/home/views/home_view.dart` - 메인 화면
- [ ] `lib/features/home/viewmodels/home_viewmodel.dart` - 집계 ViewModel
- [ ] `lib/features/home/widgets/daily_progress_ring.dart` - 원형 프로그레스
- [ ] `lib/features/home/widgets/routine_section.dart` - 루틴 섹션
- [ ] `lib/features/home/widgets/task_section.dart` - 할 일 섹션
- [ ] `lib/features/home/widgets/add_bottom_sheet.dart` - FAB 선택 시트
- [ ] F2, F3의 RoutineTile, TaskTile 위젯 재사용
- [ ] Widget 테스트: 섹션 렌더링, FAB 동작, 프로그레스 계산

## Step 3: Local DB Design
- [ ] 새 테이블 없음 (routines + tasks + dailyRecords 조합)

## Step 4: Local Repository Integration
- [ ] HomeRepository (또는 HomeViewModel에서 직접 여러 repo 조합)
- [ ] 체크박스 토글 → DailyRecord 업데이트 연동
- [ ] 프로그레스 실시간 계산
- [ ] 통합 테스트: 체크 → 프로그레스 업데이트

## 완료 조건
- [ ] 홈 화면에 오늘 루틴 + 할 일이 표시
- [ ] 체크박스 토글 동작
- [ ] 프로그레스 링 실시간 업데이트
- [ ] FAB로 루틴/할 일 추가 가능
- [ ] PRD AC-04-1 ~ AC-04-7 충족
