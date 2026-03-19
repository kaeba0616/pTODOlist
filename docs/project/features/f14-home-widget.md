# F14: 홈 위젯 (Android)

- **Feature ID**: F14
- **예상 기간**: 5~7일
- **상태**: `[status: in-progress]`
- **의존성**: Phase 4 완료

## 개요

Android 홈 화면 위젯 (4x2 크기)에서 오늘의 루틴 체크리스트와 진행률을 표시.
위젯에서 직접 루틴 체크 가능. `home_widget` Flutter 패키지 사용.

---

## Step 1: UX Planning & Design

- [x] `docs/ux/features/home-widget-flow.md` 사용자 여정
- [x] `docs/ux/features/home-widget-screens.md` 위젯 레이아웃

### 위젯 구성 (중형 4x2)
- 헤더: 앱 아이콘 + 날짜 + 달성률 (예: "3/7")
- 진행률 바: 수평 바 (달성률 퍼센트)
- 루틴 리스트: 최대 5개, 체크박스 + 제목

### 인터랙션
- 체크박스 탭 → 루틴 완료/미완료 토글
- 다른 영역 탭 → 앱 홈 화면으로 이동

---

## Step 2: Flutter Mock UI + Android 네이티브

### 새로 생성할 파일
- `ptodolist_front/lib/features/home_widget/services/home_widget_service.dart`
- `ptodolist_front/lib/features/home_widget/mocks/home_widget_mock.dart`
- `ptodolist_front/android/app/src/main/res/layout/home_widget_layout.xml`
- `ptodolist_front/android/app/src/main/res/xml/home_widget_info.xml`
- `ptodolist_front/android/app/src/main/kotlin/.../HomeWidgetProvider.kt`

### 테스트
- [ ] HomeWidgetService 유닛 테스트 (데이터 직렬화/역직렬화)
- [ ] 위젯 액션 콜백 테스트

---

## Step 3: DB Design

- 새로운 Hive Box 불필요
- 데이터 흐름:
  - 정방향: Hive → `HomeWidgetService.updateWidgetData()` → SharedPreferences → 네이티브 위젯
  - 역방향: 위젯 체크박스 탭 → callback URI → `handleWidgetAction()` → Hive 업데이트

---

## Step 4: Integration

### 위젯 업데이트 트리거 포인트
- [ ] 루틴 토글 시 (`home_view.dart`)
- [ ] 루틴 추가/삭제 시
- [ ] 자정 리셋 시 (`midnight_reset_service.dart`)
- [ ] 앱 포그라운드 복귀 시

### 수정할 기존 파일
- `ptodolist_front/pubspec.yaml` - `home_widget` 패키지 추가
- `ptodolist_front/lib/main.dart` - 위젯 콜백 핸들러 등록
- `ptodolist_front/lib/features/home/views/home_view.dart` - 토글 후 위젯 업데이트
- `ptodolist_front/lib/core/services/midnight_reset_service.dart` - 리셋 후 위젯 업데이트
- `android/app/src/main/AndroidManifest.xml` - 위젯 리시버 등록

---

## 완료 조건

- [ ] HomeWidgetService 테스트 통과
- [ ] Android 에뮬레이터에서 홈 위젯 추가 가능
- [ ] 위젯에서 루틴 체크 → 앱 데이터 반영
- [ ] 앱에서 루틴 체크 → 위젯 업데이트
- [ ] 자정 리셋 후 위젯 초기화
- [ ] 사용자 검토 및 승인
