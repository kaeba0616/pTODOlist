# pTODOlist - Test Strategy

## TDD 원칙

모든 기능 구현은 **Red-Green-Refactor** 사이클을 따른다:
1. **RED**: 실패하는 테스트를 먼저 작성하고 실행하여 실패 확인
2. **GREEN**: 테스트를 통과시키는 최소한의 코드 작성
3. **REFACTOR**: 테스트는 그대로 두고 코드 품질 개선

---

## 테스트 피라미드

### Unit Tests (최다)
- **Models**: 직렬화, equality, copyWith 검증
- **ViewModels**: 상태 전환, 에러 처리, 비즈니스 로직
- **Repositories**: CRUD 연산 (Mock Hive Box 사용)
- **Utils**: 날짜 포맷팅, 달성률 계산, 자정 감지

### Widget Tests (중간)
- 개별 위젯: CheckboxTile 렌더링, 체크 토글
- 화면 단위: HomeView 섹션 표시, StatsView 차트 렌더링
- 네비게이션: 탭 전환, 라우트 이동

### Integration Tests (소량, 고가치)
- 전체 플로우: 앱 실행 → 루틴 추가 → 체크 → 통계 확인
- 자정 초기화: 날짜 변경 시뮬레이션 → DailyRecord 생성 확인
- 데이터 보관: 오래된 레코드 삭제 확인

---

## 테스트 파일 구조

```
ptodolist_front/test/
├── features/
│   ├── category/
│   │   ├── models/category_test.dart
│   │   ├── viewmodels/category_viewmodel_test.dart
│   │   ├── repos/category_repo_test.dart
│   │   └── views/category_list_view_test.dart
│   ├── routine/
│   │   ├── models/routine_test.dart
│   │   ├── viewmodels/routine_viewmodel_test.dart
│   │   ├── repos/routine_repo_test.dart
│   │   └── views/routine_form_view_test.dart
│   ├── task/
│   │   └── ...
│   ├── home/
│   │   ├── models/daily_record_test.dart
│   │   ├── viewmodels/home_viewmodel_test.dart
│   │   └── views/home_view_test.dart
│   ├── stats/
│   │   └── ...
│   └── settings/
│       └── ...
├── core/
│   ├── services/midnight_reset_service_test.dart
│   ├── services/data_cleanup_service_test.dart
│   └── utils/date_utils_test.dart
└── integration_test/
    ├── app_flow_test.dart
    └── midnight_reset_test.dart
```

---

## Mock 전략

- `mocktail` 패키지로 Hive Box, Service 등 모킹
- 각 Feature의 `mocks/` 디렉토리에 리얼리스틱한 테스트 데이터
- Mock Provider 패턴으로 ViewModel 테스트 시 실제 DB 불필요

---

## 커버리지 목표

| 레이어 | 목표 |
|---|---|
| Models | 100% |
| ViewModels | 90%+ |
| Repositories | 90%+ |
| Utils / Services | 90%+ |
| Widgets | 80%+ |
| Integration | 주요 플로우 5개+ |

---

## 테스트 실행

```bash
# 전체 테스트
flutter test

# 커버리지 포함
flutter test --coverage

# 특정 파일
flutter test test/features/routine/models/routine_test.dart

# 통합 테스트
flutter test integration_test/
```
