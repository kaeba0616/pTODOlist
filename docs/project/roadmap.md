# pTODOlist - Roadmap

## Phase 개요

| Phase | 이름 | 목표 | Features | 상태 |
|---|---|---|---|---|
| Phase 1 | Core Foundation | 루틴+할일 관리, 자정 리셋 | F0~F5 | `[status: done]` |
| Phase 2 | Engagement | 통계, 스마트 알림 | F6~F7 | `[status: done]` |
| Phase 3 | Polish | 설정, 데이터 관리, 테마 | F8 | `[status: done]` |
| Phase 4 | Enhancement | 요일별 루틴, 연속 달성, 마감일 | F9~F12 | `[status: done]` |
| Phase 5 | Visualization & Reach | 캘린더 뷰, 홈 위젯 | F13~F14 | `[status: in-progress]` |

---

## Phase 1: Core Foundation `[status: done]`

**목표**: 사용자가 루틴과 할 일을 관리하고 매일 완료 여부를 체크할 수 있는 기본 앱

**Features**:
| ID | 기능 | 의존성 | 상태 |
|---|---|---|---|
| F0 | 앱 셸 & 네비게이션 | - | `[status: completed]` |
| F1 | 카테고리 관리 | F0 | `[status: completed]` |
| F2 | 루틴 관리 | F1 | `[status: completed]` |
| F3 | 추가 할 일 | F1 | `[status: completed]` |
| F4 | 오늘 화면 | F2, F3 | `[status: completed]` |
| F5 | 일일 기록 & 자정 리셋 | F4 | `[status: completed]` |

**마일스톤**: 앱 실행 → 루틴 추가 → 체크 → 자정 리셋 → 다음 날 새로 시작

---

## Phase 2: Engagement `[status: done]`

**목표**: 사용자가 달성률을 확인하고 알림으로 동기부여 받을 수 있음

**Features**:
| ID | 기능 | 의존성 | 상태 |
|---|---|---|---|
| F6 | 달성률 통계 | F5 | `[status: completed]` |
| F7 | 11시 스마트 알림 | F5 | `[status: completed]` |

**마일스톤**: 통계 차트 확인 + 11시 미완료 알림 수신

---

## Phase 3: Polish `[status: done]`

**목표**: 사용자 설정 커스터마이징 및 데이터 관리

**Features**:
| ID | 기능 | 의존성 | 상태 |
|---|---|---|---|
| F8 | 설정 & 데이터 관리 | F7 | `[status: completed]` |

**마일스톤**: 알림/테마/보관기간 설정 가능, 오래된 데이터 자동 정리

---

## Phase 4: Enhancement `[status: done]`

**목표**: 기술 부채 정리 + 요일별 루틴, 연속 달성, 할 일 마감일로 사용성 향상

**Features**:
| ID | 기능 | 의존성 | 상태 |
|---|---|---|---|
| F9 | Subtask & Edit Cleanup | - | `[status: completed]` |
| F10 | 요일별 루틴 | F9 | `[status: completed]` |
| F11 | 연속 달성 추적 (Streak) | F10 | `[status: completed]` |
| F12 | 할 일 마감일 | F9 | `[status: completed]` |

**마일스톤**: 요일별 루틴 필터링 + 연속 달성 뱃지 + overdue 할 일 표시

---

## Phase 5: Visualization & Reach `[status: in-progress]`

**목표**: 캘린더 히트맵으로 과거 달성률 시각화 + 홈 위젯으로 앱 없이 루틴 체크

**Features**:
| ID | 기능 | 의존성 | 상태 |
|---|---|---|---|
| F13 | 캘린더 뷰 (달력) | Phase 4 완료 | `[status: todo]` |
| F14 | 홈 위젯 (Android) | Phase 4 완료 | `[status: todo]` |

**마일스톤**: 월별 캘린더 히트맵 + Android 홈 위젯에서 루틴 체크

---

## 리스크 & 완화 전략

| 리스크 | 영향 | 완화 |
|---|---|---|
| Hive isolate 재초기화 이슈 | F7 알림 | 조기 테스트, 필요시 drift(SQLite)로 전환 |
| iOS 백그라운드 제한 | F7 알림 | 폴백 전략 + 제한사항 문서화 |
| 자정 리셋 타임존 엣지케이스 | F5 리셋 | UTC 기반 + 로컬 변환, 모킹된 시계로 테스트 |

---

## Phase 간 규칙
- Phase N+1은 Phase N의 모든 Feature가 `[status: completed]`일 때 시작
- Phase 2+ 상세 계획은 이전 Phase 완료 직전에 작성
