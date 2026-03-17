# F2: 루틴 관리

**Feature ID**: F2
**예상 기간**: 4일
**상태**: `[status: todo]`
**의존성**: F1

---

## Step 1: UX Planning & Design
- [ ] 루틴 추가 폼 (제목, 카테고리 선택)
- [ ] 루틴 수정/삭제/비활성화 인터랙션
- [ ] 드래그 순서 변경 UX
- [ ] `docs/ux/features/routine-flow.md` 작성
- [ ] `docs/ux/features/routine-screens.md` 작성

## Step 2: Flutter Mock UI
- [ ] `lib/features/routine/models/routine.dart` - freezed 모델
- [ ] `lib/features/routine/mocks/routine_mock.dart` - 8~10개 Mock
- [ ] `lib/features/routine/repos/routine_repo.dart` - Mock Provider
- [ ] `lib/features/routine/viewmodels/routine_viewmodel.dart`
- [ ] `lib/features/routine/views/routine_form_view.dart` - 추가/수정 폼
- [ ] `lib/features/routine/widgets/routine_tile.dart` - 체크박스 타일
- [ ] Unit 테스트: Routine 모델
- [ ] Widget 테스트: 추가 폼, 타일 렌더링

## Step 3: Local DB Design
- [ ] Routine Hive TypeAdapter (typeId: 1)
- [ ] `routines` 박스 등록

## Step 4: Local Repository Integration
- [ ] Real RoutineRepository (Hive 연동)
- [ ] 활성 루틴만 필터 (`isActive == true`)
- [ ] 순서 변경 로직 (`order` 필드 업데이트)
- [ ] 통합 테스트: CRUD + 필터 + 정렬

## 완료 조건
- [ ] 루틴 추가/수정/삭제/비활성화 동작
- [ ] 순서 드래그 변경 동작
- [ ] 앱 재시작 시 데이터 유지
- [ ] PRD AC-02-1 ~ AC-02-6 충족
