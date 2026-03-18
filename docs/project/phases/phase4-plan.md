# Phase 4: Enhancement - 상세 계획

**목표**: 기술 부채 정리 + 핵심 사용성 개선
**기간**: 약 8~11일
**상태**: `[status: in-progress]`

---

## Feature 목록

### F9: Subtask & Edit Cleanup `[status: in-progress]`
- **Feature ID**: F9
- **예상 기간**: 1~2일
- **의존성**: 없음

기존 subtask/편집 기능의 UX 문서, 테스트, 리팩터링 정리.

### F10: 요일별 루틴 (Day-of-Week Routines) `[status: todo]`
- **Feature ID**: F10
- **예상 기간**: 3~4일
- **의존성**: F9

루틴에 활성 요일 설정 추가. 홈 화면에서 오늘 요일 기준 필터링.

### F11: 연속 달성 추적 (Streak Tracking) `[status: todo]`
- **Feature ID**: F11
- **예상 기간**: 2~3일
- **의존성**: F10

DailyRecord 기반 연속 달성일수 계산 및 표시.

### F12: 할 일 마감일 (Due Dates for Tasks) `[status: todo]`
- **Feature ID**: F12
- **예상 기간**: 2일
- **의존성**: F9

할 일에 미래 날짜 지정 가능. 미완료 지난 할 일 overdue 표시.

---

## 개발 원칙
- UI-First Mock-Driven Development
- TDD (Red-Green-Refactor)
- 각 Feature는 4단계 프로세스 (UX → Mock UI → DB → Integration)

## Feature 간 의존성
```
F9 (Subtask & Edit Cleanup)
├── F10 (요일별 루틴) → F11 (Streak)
└── F12 (할 일 마감일)
```

## 상세 문서
- `docs/project/features/f9-subtask-cleanup.md`
- `docs/project/features/f10-weekday-routine.md`
- `docs/project/features/f11-streak.md`
- `docs/project/features/f12-due-dates.md`
