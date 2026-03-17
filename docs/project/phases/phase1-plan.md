# Phase 1: Core Foundation

## 개요
사용자가 루틴과 할 일을 관리하고, 매일 완료 여부를 체크하며,
자정에 자동 초기화되는 기본 앱을 구현한다.

**개발 원칙**: UI-First Mock-Driven Development (CLAUDE.md 2.4)
**4단계 프로세스**: Step 1 (UX) → Step 2 (Mock UI) → Step 3 (DB) → Step 4 (Integration)

---

## Features

| ID | 기능 | 상태 | 상세 계획 |
|---|---|---|---|
| F0 | 앱 셸 & 네비게이션 | `[status: completed]` | `docs/project/features/f0-app-shell.md` |
| F1 | 카테고리 관리 | `[status: todo]` | `docs/project/features/f1-category.md` |
| F2 | 루틴 관리 | `[status: todo]` | `docs/project/features/f2-routine.md` |
| F3 | 추가 할 일 | `[status: todo]` | `docs/project/features/f3-task.md` |
| F4 | 오늘 화면 | `[status: todo]` | `docs/project/features/f4-home.md` |
| F5 | 일일 기록 & 자정 리셋 | `[status: todo]` | `docs/project/features/f5-daily-record.md` |

---

## Feature 의존성

```
F0 (앱 셸) → F1 (카테고리) → F2 (루틴) → F4 (오늘 화면) → F5 (일일 기록)
                            → F3 (할 일) → F4
```

- F0: 모든 Feature의 기반 (테마, 라우터, Hive 초기화)
- F1: F2, F3의 전제 (루틴/할 일이 카테고리 참조)
- F2, F3: 병렬 진행 가능 (서로 의존 없음)
- F4: F2, F3 모델 필요
- F5: F4의 체크박스 인터랙션 위에 DailyRecord 레이어 추가

---

## 실행 순서

### F0: 앱 셸 & 네비게이션
1. Step 1: `docs/ux/features/app-shell-flow.md`, `app-shell-screens.md`
2. Step 2: Flutter 프로젝트 생성, 테마, go_router, 플레이스홀더 화면
3. Step 3: Hive 초기화, AppSettings 박스
4. Step 4: AppSettingsRepository 연동, 초기화 테스트

### F1: 카테고리 관리
1. Step 1: `docs/ux/features/category-flow.md`, `category-screens.md`
2. Step 2: Category 모델, Mock, ViewModel, ListView, EditSheet
3. Step 3: Hive TypeAdapter, 기본 시드
4. Step 4: Real Repository, CRUD 통합테스트

### F2: 루틴 관리
1. Step 1: `docs/ux/features/routine-flow.md`, `routine-screens.md`
2. Step 2: Routine 모델, Mock, ViewModel, FormView, RoutineTile
3. Step 3: Hive TypeAdapter
4. Step 4: Real Repository, 정렬/필터 테스트

### F3: 추가 할 일
1. Step 1: `docs/ux/features/task-flow.md`, `task-screens.md`
2. Step 2: AdditionalTask 모델, Mock, ViewModel, FormView, TaskTile
3. Step 3: Hive TypeAdapter
4. Step 4: Real Repository, 날짜/완료 필터 테스트

### F4: 오늘 화면
1. Step 1: `docs/ux/features/home-flow.md`, `home-screens.md`
2. Step 2: HomeView, HomeViewModel, ProgressRing, 섹션 위젯
3. Step 3: 새 테이블 없음 (기존 데이터 조합)
4. Step 4: 집계 Repository, 체크 토글 연동

### F5: 일일 기록 & 자정 리셋
1. Step 1: `docs/ux/features/daily-record-flow.md`
2. Step 2: DailyRecord 모델, 30일 Mock, 날짜 감지 Mock
3. Step 3: Hive TypeAdapter, daily_records 박스
4. Step 4: DailyRecordRepository, MidnightResetService, 3중 체크 테스트

---

## 완료 기준
- [ ] 모든 Feature가 `[status: completed]`
- [ ] 전체 테스트 통과 (`flutter test`)
- [ ] 실기기에서 루틴 추가 → 체크 → 앱 재시작 → 데이터 유지 확인
- [ ] 날짜 변경 시 자정 초기화 동작 확인
