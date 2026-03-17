# F1: 카테고리 관리

**Feature ID**: F1
**예상 기간**: 3일
**상태**: `[status: in-progress]`
**의존성**: F0

---

## Step 1: UX Planning & Design
- [ ] 카테고리 목록 화면 설계
- [ ] 카테고리 추가/수정 바텀시트 설계
- [ ] 삭제 시 "기타"로 재할당 플로우
- [ ] `docs/ux/features/category-flow.md` 작성
- [ ] `docs/ux/features/category-screens.md` 작성

## Step 2: Flutter Mock UI
- [ ] `lib/features/category/models/category.dart` - freezed 모델
- [ ] `lib/features/category/mocks/category_mock.dart` - 5개 기본 Mock
- [ ] `lib/features/category/repos/category_repo.dart` - Mock Provider
- [ ] `lib/features/category/viewmodels/category_viewmodel.dart` - Riverpod
- [ ] `lib/features/category/views/category_list_view.dart` - 목록 화면
- [ ] `lib/features/category/views/category_edit_view.dart` - 추가/수정 시트
- [ ] `lib/features/category/widgets/category_tile.dart` - 색상 도트 + 이름
- [ ] Unit 테스트: Category 모델 직렬화
- [ ] Widget 테스트: 목록 렌더링, 추가, 삭제 플로우

## Step 3: Local DB Design
- [ ] Category Hive TypeAdapter (typeId: 0)
- [ ] `categories` 박스 등록
- [ ] 첫 실행 시 기본 카테고리 5개 시드 로직
- [ ] `docs/tech/db-schema.md` 확정

## Step 4: Local Repository Integration
- [ ] Real CategoryRepository (Hive 연동)
- [ ] Mock → Real 전환 (USE_MOCK 환경변수)
- [ ] "기타" 카테고리 삭제 방지 로직
- [ ] 카테고리 삭제 시 연관 루틴/할일 재할당
- [ ] 통합 테스트: CRUD + 재할당 + 시드

## 완료 조건
- [ ] 카테고리 목록/추가/수정/삭제가 동작
- [ ] 앱 재시작 시 데이터 유지
- [ ] "기타" 삭제 불가
- [ ] PRD AC-01-1 ~ AC-01-6 충족
