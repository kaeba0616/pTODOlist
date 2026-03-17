# pTODOlist - Roadmap

## Phase 개요

| Phase | 이름 | 목표 | Features | 상태 |
|---|---|---|---|---|
| Phase 1 | Core Foundation | 루틴+할일 관리, 자정 리셋 | F0~F5 | `[status: done]` |
| Phase 2 | Engagement | 통계, 스마트 알림 | F6~F7 | `[status: done]` |
| Phase 3 | Polish | 설정, 데이터 관리, 테마 | F8 | `[status: planned]` |

---

## Phase 1: Core Foundation `[status: planned]`

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

## Phase 2: Engagement `[status: planned]`

**목표**: 사용자가 달성률을 확인하고 알림으로 동기부여 받을 수 있음

**Features**:
| ID | 기능 | 의존성 | 상태 |
|---|---|---|---|
| F6 | 달성률 통계 | F5 | `[status: completed]` |
| F7 | 11시 스마트 알림 | F5 | `[status: completed]` |

**마일스톤**: 통계 차트 확인 + 11시 미완료 알림 수신

---

## Phase 3: Polish `[status: planned]`

**목표**: 사용자 설정 커스터마이징 및 데이터 관리

**Features**:
| ID | 기능 | 의존성 | 상태 |
|---|---|---|---|
| F8 | 설정 & 데이터 관리 | F7 | `[status: todo]` |

**마일스톤**: 알림/테마/보관기간 설정 가능, 오래된 데이터 자동 정리

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
