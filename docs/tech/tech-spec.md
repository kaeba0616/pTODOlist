# pTODOlist - Tech Spec

## 1. 기술 아키텍처

### 스택 개요
| 레이어 | 기술 | 비고 |
|---|---|---|
| UI | Flutter (Material 3) | iOS + Android 단일 코드 |
| 상태관리 | Riverpod (AsyncNotifier) | 반응형 상태 + DI |
| 라우팅 | go_router (ShellRoute) | 선언적 라우팅 + 바텀 탭 |
| 로컬 DB | Hive + hive_flutter | NoSQL, 빠른 읽기/쓰기 |
| 모델 | freezed + json_serializable | Immutable 모델 + 코드 생성 |
| 알림 | flutter_local_notifications | 로컬 푸시 알림 |
| 백그라운드 | workmanager | 11시 스마트 알림용 |
| 차트 | fl_chart | 통계 시각화 |
| 테스트 | mocktail | Mock 기반 유닛 테스트 |

### 아키텍처 레이어
```
Views (Widget) → ViewModels (Riverpod) → Repositories → Hive Boxes
```

- **Views**: Flutter Widget, UI 렌더링만 담당
- **ViewModels**: Riverpod AsyncNotifier, 비즈니스 로직 + 상태 관리
- **Repositories**: 데이터 접근 레이어, Mock/Real 전환 가능
- **Hive Boxes**: 로컬 저장소

---

## 2. 모듈 구조

### Feature-based 구조
각 기능은 독립적인 디렉토리에 다음 하위 구조를 가진다:
```
features/<feature>/
├── models/       # freezed 모델
├── mocks/        # Mock 데이터
├── repos/        # Repository (Mock + Real)
├── viewmodels/   # Riverpod providers
├── views/        # 화면 Widget
└── widgets/      # 재사용 위젯
```

### Core 모듈
```
core/
├── theme/        # AppTheme, 색상, 타이포 토큰
├── router/       # go_router 설정
├── db/           # Hive 초기화, 마이그레이션
├── services/     # 앱 전역 서비스 (자정 리셋, 알림, 데이터 정리)
└── utils/        # 날짜 유틸 등
```

---

## 3. 상태관리 패턴

### Riverpod AsyncNotifier
```dart
// ViewModel 패턴
@riverpod
class RoutineList extends _$RoutineList {
  @override
  Future<List<Routine>> build() async {
    final repo = ref.watch(routineRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(Routine routine) async { ... }
  Future<void> toggle(String id) async { ... }
}
```

### Mock Provider 패턴 (CLAUDE.md 준수)
```dart
// Repository with mock switch
class RoutineRepository {
  final bool useMock;
  final Box<Routine>? _box;

  RoutineRepository({this.useMock = false, Box<Routine>? box}) : _box = box;

  Future<List<Routine>> getAll() async {
    if (useMock) return mockRoutines;
    return _box!.values.toList();
  }
}

// Provider
final routineRepositoryProvider = Provider((ref) {
  final useMock = const String.fromEnvironment('USE_MOCK') == 'true';
  if (useMock) return RoutineRepository(useMock: true);
  final box = ref.watch(routineBoxProvider);
  return RoutineRepository(box: box);
});
```

---

## 4. 라우팅 구조

### go_router with ShellRoute
```
/                → 홈 화면 (오늘 탭)
/stats           → 통계 화면
/settings        → 설정 화면
/settings/categories → 카테고리 관리
/add-routine     → 루틴 추가 (모달)
/add-task        → 할 일 추가 (모달)
```

ShellRoute로 바텀 네비게이션을 감싸고, 모달 화면은 별도 route로 처리.

---

## 5. 데이터 흐름

### 루틴 체크 플로우
```
User taps checkbox
  → HomeViewModel.toggleRoutineCompletion(routineId)
    → DailyRecordRepository.toggleCompletion(today, routineId)
      → Hive Box update
    → ref.invalidateSelf() (리빌드 트리거)
  → UI 업데이트 (체크 애니메이션 + 프로그레스 링)
```

### 자정 초기화 플로우
```
MidnightResetService detects date change
  → DailyRecordRepository.getOrCreateToday()
    → New DailyRecord created with all active routines = false
    → Hive Box put(todayKey, newRecord)
  → All watching providers invalidated
  → UI rebuilds with fresh state
```

---

## 6. 의존성 목록 (pubspec.yaml)

### dependencies
```yaml
flutter_riverpod: ^2.x
riverpod_annotation: ^2.x
go_router: ^14.x
hive: ^2.x
hive_flutter: ^1.x
fl_chart: ^0.x
flutter_local_notifications: ^17.x
workmanager: ^0.5.x
freezed_annotation: ^2.x
json_annotation: ^4.x
uuid: ^4.x
intl: ^0.x
```

### dev_dependencies
```yaml
freezed: ^2.x
json_serializable: ^6.x
build_runner: ^2.x
riverpod_generator: ^2.x
hive_generator: ^2.x
mocktail: ^1.x
riverpod_lint: ^2.x
```

---

## 7. 환경 설정

### Mock 모드
```bash
# Mock 데이터로 실행 (백엔드/DB 없이)
flutter run --dart-define=USE_MOCK=true

# Real Hive DB로 실행
flutter run
```

### 빌드
```bash
# 코드 생성 (freezed, hive adapter, riverpod)
dart run build_runner build --delete-conflicting-outputs

# 테스트
flutter test

# 앱 실행
flutter run
```
