# F3: 추가 할 일

**Feature ID**: F3
**예상 기간**: 3일
**상태**: `[status: todo]`
**의존성**: F1

---

## Step 1: UX Planning & Design
- [ ] 할 일 추가 폼 (제목, 카테고리, 날짜)
- [ ] 완료 토글, 완료 항목 하단 이동 UX
- [ ] 스와이프 삭제 인터랙션
- [ ] `docs/ux/features/task-flow.md` 작성
- [ ] `docs/ux/features/task-screens.md` 작성

## Step 2: Flutter Mock UI
- [ ] `lib/features/task/models/additional_task.dart` - freezed 모델
- [ ] `lib/features/task/mocks/task_mock.dart` - Mock 데이터
- [ ] `lib/features/task/repos/task_repo.dart` - Mock Provider
- [ ] `lib/features/task/viewmodels/task_viewmodel.dart`
- [ ] `lib/features/task/views/task_form_view.dart` - 추가/수정 폼
- [ ] `lib/features/task/widgets/task_tile.dart` - 체크+취소선 타일
- [ ] Unit 테스트: AdditionalTask 모델
- [ ] Widget 테스트: 완료 토글, 하단 이동

## Step 3: Local DB Design
- [ ] AdditionalTask Hive TypeAdapter (typeId: 2)
- [ ] `additionalTasks` 박스 등록

## Step 4: Local Repository Integration
- [ ] Real TaskRepository (Hive 연동)
- [ ] 날짜별 필터 (`targetDate`)
- [ ] 완료 상태 필터 (`isCompleted`)
- [ ] 통합 테스트: CRUD + 필터

## 완료 조건
- [ ] 할 일 추가/완료/삭제 동작
- [ ] 완료 항목이 하단으로 이동
- [ ] 자정에 자동 초기화되지 않음 (루틴과 다름)
- [ ] PRD AC-03-1 ~ AC-03-5 충족
