# F9: Subtask & Edit Cleanup

- **Feature ID**: F9
- **예상 기간**: 1~2일
- **상태**: `[status: in-progress]`
- **의존성**: 없음

## 개요
7a33f34 커밋에서 추가된 subtask/편집 기능의 기술 부채 정리.
UX 문서 작성, 테스트 추가, operator==/hashCode 수정, _parseColor 중복 제거.

## Step 1: UX Planning & Design
- [x] `docs/ux/features/subtask-flow.md` 작성
- [x] `docs/ux/features/subtask-screens.md` 작성

## Step 2: 테스트 추가 (TDD)
- [x] Routine 모델 subtasks 테스트 (생성, copyWith, equality)
- [x] AdditionalTask 모델 subtasks 테스트 (생성, copyWith, equality)
- [x] RoutineRepository subtasks 테스트 (추가, 수정)
- [x] TaskRepository subtasks 테스트 (추가, 수정)
- [x] operator==/hashCode에 subtasks 포함 (RED → GREEN)

## Step 3: 리팩터링
- [x] `_parseColor` → `parseHexColor` 공유 유틸리티 추출 (6곳)
- [x] PRD에 subtask/편집 AC 추가 (US-02, US-03)

## 완료 조건
- [x] 전체 테스트 통과 (78 → 92개)
- [x] `_parseColor` 중복 제거 완료
- [x] UX 문서 작성 완료
- [x] PRD AC 업데이트 완료
