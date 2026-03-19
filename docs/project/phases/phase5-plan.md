# Phase 5: Visualization & Reach

**목표**: 캘린더 히트맵으로 과거 달성률 시각화 + 홈 위젯으로 앱 없이 루틴 체크

**상태**: `[status: in-progress]`

---

## Features

| ID | 기능 | 의존성 | 예상 기간 | 상태 |
|---|---|---|---|---|
| F13 | 캘린더 뷰 (달력) | Phase 4 완료 | 3~4일 | `[status: completed]` |
| F14 | 홈 위젯 (Android) | Phase 4 완료 | 5~7일 | `[status: todo]` |

---

## 개발 원칙

- UI-First Mock-Driven Development
- TDD (Red-Green-Refactor)
- 4단계 프로세스: UX Planning → Mock UI → DB Design → Integration

---

## Feature 간 의존성

```
F13 (캘린더 뷰) ──┐
                   ├── 독립적 (의존성 없음)
F14 (홈 위젯)  ──┘
```

F13 → F14 순서로 진행 (F13은 순수 Flutter, F14는 네이티브 코드 필요)

---

## 타임라인

| 기간 | 작업 |
|---|---|
| 1일차 | Phase 5 문서 작성 + F13 UX Planning |
| 2~4일차 | F13 Mock UI + DB + Integration |
| 5일차 | F14 UX Planning |
| 6~10일차 | F14 Mock UI + 네이티브 코드 + Integration |

---

## 마일스톤

- 월별 캘린더 히트맵에서 날짜별 달성률 확인 + 일별 상세 조회
- Android 홈 화면 위젯에서 루틴 체크리스트 확인 및 체크 가능
