# 홈 위젯 (F14) - User Flow

## 개요

Android 홈 화면에 위젯을 배치하여 앱을 열지 않고도
오늘의 루틴 진행 상황을 확인하고 체크할 수 있다.

---

## 위젯 추가 경로

1. 사용자가 Android 홈 화면을 길게 누른다
2. "위젯" 메뉴를 선택한다
3. "pTODOlist" 위젯을 찾아 홈 화면에 드래그한다
4. 위젯이 오늘의 루틴 체크리스트를 표시한다

---

## Flow 1: 위젯에서 루틴 상태 확인

1. 사용자가 홈 화면의 위젯을 본다
2. 헤더에 오늘 날짜와 달성률 (예: "3/7")이 표시된다
3. 진행률 바가 현재 달성률을 시각적으로 보여준다
4. 루틴 리스트에 오늘의 루틴 최대 5개가 표시된다
5. 각 루틴 옆에 체크박스로 완료 여부가 표시된다

```
홈 화면 위젯
  ↓
SharedPreferences에서 캐시된 데이터 읽기
  ↓
날짜 + 달성률 + 루틴 리스트 렌더링
```

---

## Flow 2: 위젯에서 루틴 체크

1. 사용자가 위젯의 루틴 체크박스를 탭한다
2. 위젯이 즉시 UI를 업데이트한다 (optimistic update)
3. Flutter 앱이 백그라운드에서 Hive 데이터를 업데이트한다
4. 위젯의 달성률과 진행률 바가 갱신된다

```
체크박스 탭
  ↓
home_widget callback URI: "ptodolist://toggle?routineId=xxx"
  ↓
HomeWidgetService.handleWidgetAction()
  ↓
DailyRecordRepo.toggleRoutineCompletion()
  ↓
HomeWidgetService.updateWidgetData()
  ↓
위젯 리프레시
```

---

## Flow 3: 앱에서 변경 → 위젯 동기화

1. 사용자가 앱에서 루틴을 체크한다
2. HomeWidgetService.updateWidgetData()가 호출된다
3. SharedPreferences에 최신 데이터가 저장된다
4. 네이티브 위젯이 리프레시된다

### 트리거 포인트
- 루틴 토글 시 (home_view.dart `_toggleRoutine`)
- 루틴 추가/삭제 시
- 자정 리셋 시 (midnight_reset_service.dart)
- 앱 포그라운드 복귀 시

---

## Flow 4: 위젯 영역 탭 → 앱 열기

1. 사용자가 위젯의 체크박스가 아닌 영역을 탭한다
2. pTODOlist 앱이 열린다
3. 홈 탭 (오늘 화면)이 표시된다

---

## Flow 5: 자정 리셋

1. 자정이 지나면 workmanager 주기 작업이 실행된다
2. DailyRecord가 새 날짜로 초기화된다
3. SharedPreferences에 새 날짜 데이터가 저장된다
4. 위젯이 리프레시되어 새로운 체크리스트를 표시한다

---

## 데이터 흐름 (정방향)

```
Hive (DailyRecord + Routine)
  ↓
HomeWidgetService.updateWidgetData()
  ↓
SharedPreferences / UserDefaults (JSON)
  ↓
Native Widget 렌더링
```

## 데이터 흐름 (역방향 - 위젯 탭)

```
Native Widget 체크박스 탭
  ↓
home_widget callback URI
  ↓
HomeWidgetService.handleWidgetAction()
  ↓
DailyRecordRepository.toggleRoutineCompletion()
  ↓
HomeWidgetService.updateWidgetData()
  ↓
Widget 리프레시
```

---

## Edge Cases

| 상황 | 처리 |
|---|---|
| 루틴이 0개 | "루틴을 추가해보세요" 메시지 표시 |
| 루틴이 5개 초과 | 상위 5개만 표시, "+N개 더" 텍스트 |
| 앱 미설치 상태에서 위젯 탭 | 앱 실행으로 폴백 |
| 자정 전후 위젯 업데이트 지연 | workmanager 15분 주기로 보정 |
| 앱 데이터 초기화 | 위젯도 빈 상태로 업데이트 |
