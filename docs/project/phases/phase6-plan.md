# Phase 6: Cloud & Social

**목표**: Google 로그인 + 클라우드 동기화로 멀티 디바이스를 지원하고,
친구와 루틴 진행률을 공유하는 소셜 모티베이션을 추가

**상태**: `[status: done]`

---

## Features

| ID | 기능 | 의존성 | 예상 기간 | 상태 |
|---|---|---|---|---|
| F15 | 클라우드 계정 + 데이터 동기화 | Phase 5 완료 | 7~10일 | `[status: completed]` |
| F16 | 친구 공유 | F15 | 5~7일 | `[status: completed]` |

상세 계획: [`f15-cloud-sync.md`](../features/f15-cloud-sync.md), [`f16-friends.md`](../features/f16-friends.md)

---

## 개발 원칙

- TDD (Red-Green-Refactor)
- Cloud-first 아키텍처: Firestore 가 SoT, Hive 는 로컬 캐시
- Security 우선: Firestore Security Rules 로 친구 외 접근 차단
- 비용 최소화: 폴링 금지, 이벤트 기반 sync tick

---

## Feature 간 의존성

```
F15 (클라우드 동기화)
    │
    └── F16 (친구 공유)   ← F15 의 publicMode/profile/dailyShare 인프라 활용
```

F15 → F16 순서 필수 (F16 은 F15 의 프로필, dailyShare, Firestore 인프라 위에 동작).

---

## 타임라인 (회고)

| 기간 | 작업 |
|---|---|
| 1~2일차 | F15 Step 1: Firebase 인프라 + Android 통합 |
| 3일차 | F15 Step 2: Google 로그인 |
| 4일차 | F15 Step 3: 프로필 (닉네임/publicMode) |
| 5~6일차 | F15 Step 4: dailyShare 단방향 sync |
| 7~10일차 | F15 Step 5: Cloud-first 전환 + 자동 마이그레이션 + 글로벌 sync tick |
| 11일차 | F16 Step 1: publicMode 단순화 + 친구 코드 발급 |
| 12일차 | F16 Step 2: 친구 관계 모델 + repo |
| 13일차 | F16 Step 3: 친구 화면 UI |
| 14일차 | F16 Step 4: 친구 상세 (dailyShare) |
| 15일차 | F16 Step 5: Firestore Security Rules |
| 16일차 | F16 Step 6: 친구 상세 보강 (전체 루틴 리스트) + 버그 픽스 |

---

## 마일스톤

- Google 로그인으로 멀티 디바이스에서 같은 데이터 사용
- 친구 코드로 친구 추가 → 친구의 루틴 + 오늘 진행률 확인
- Firestore Security Rules 로 비친구 read 차단

---

## 비용

Firebase Spark (무료) 한도 내에서 운영. 현재 사용자 규모 (개인 + 친구) 에서 월 $0.
활성 사용자 100명까지 무료 가능 (reads 50K/일 한도 기준).

---

## 회고 / 학습

**잘된 점**:
- Cloud-first 로 전환하면서 silent fail 진단 (SnackBar, ForcePushResult, 강제 동기화 버튼)
  을 적극 추가해서 버그 잡는 속도가 빨랐음
- 글로벌 sync tick (ValueNotifier) 패턴으로 모든 뷰가 자동 새로고침 — 간단하고 효과적
- Firestore Security Rules 를 친구 모델에 맞춰 일찍 잡아서 프라이버시 보장

**아쉬운 점**:
- F15 를 roadmap 에 사전 등록하지 않고 ad-hoc 으로 진행 → 이 문서로 retroactive 정리
- iOS Firebase 통합은 미구현 (Android only) — 추후 Phase 에서 다뤄야 함
- 양방향 실시간 동기화는 미구현 (변경 발생 시 다른 기기는 sync tick 안 옴)

**다음 Phase 후보**:
- iOS Firebase + iOS 홈 위젯
- 친구 상호작용 강화 (streak / 주간 진행률 / 응원)
- 알림 확장 (친구 루틴 완료 시 알림 등)
- 유료화 (Pro 기능 분리)
