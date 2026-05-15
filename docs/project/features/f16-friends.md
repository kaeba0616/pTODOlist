# F16: 친구 공유

- **Feature ID**: F16
- **예상 기간**: 5~7일 (실 소요: ~7일)
- **상태**: `[status: completed]`
- **의존성**: F15 (클라우드 동기화)

## 개요

친구 코드로 친구를 추가하고, 친구의 등록된 루틴 + 오늘 진행률을 볼 수 있다.
"다른 사람도 열심히 하는구나" 라는 소셜 모티베이션을 제공한다.

**핵심 가치**:
- 친구가 등록한 루틴 목록과 오늘 달성 여부를 볼 수 있음
- 본인의 할 일 (개인 TODO) 은 비공개로 유지
- Firestore Security Rules 로 친구 관계가 아닌 사용자는 접근 차단

**프라이버시 정책**:
- `routines`, `categories`, `dailyRecords`, `dailyShares` — **친구만 read 가능**
- `tasks` — **본인만 접근 가능** (친구도 못 봄)

---

## Step 1: publicMode 단순화 + 친구 코드 자동 발급

**커밋**: `54db550 feat(F15-5-1): publicMode 단순화 + 친구 코드 자동 발급`

- [x] `publicMode` enum 단순화: `none`, `friends` (기존 `public` 옵션 제거)
- [x] 프로필 생성 시 `friendCode` 자동 발급
  - 형식: `XXXX-XXXX` (8자리 영숫자 + 가독성 하이픈)
  - 충돌 검사 후 unique 보장
- [x] 설정 화면에 친구 코드 표시 + 복사 버튼

---

## Step 2: 친구 관계 데이터 모델 + Repository

**커밋**: `416b261 feat(F15-5-2): 친구 관계 데이터 모델 + repository`

- [x] `lib/features/friends/models/friendship.dart` (freezed)
  - 필드: `fromUid`, `toUid`, `createdAt`, `status` (pending/accepted)
- [x] `lib/features/friends/repos/friends_repo.dart`
  - `addByFriendCode(code)` — 친구 코드로 friendship 문서 생성
  - `findUidByFriendCode(code)` — 코드 → uid 역조회
  - `watchFriends(uid)` — 내 친구 목록 스트림
  - `watchIncoming(uid)` — 들어온 친구 요청 스트림
- [x] Firestore 경로: `/friendships/{fromUid}_{toUid}`

---

## Step 3: 친구 화면 UI + 설정 진입점

**커밋**: `793e6e5 feat(F15-5-3): 친구 화면 UI + 설정 진입점`

- [x] `lib/features/friends/views/friends_view.dart`
  - 친구 목록 (각 친구의 닉네임 + 오늘 진행률 미리보기)
  - "+" 버튼 → 친구 코드 입력 다이얼로그
- [x] 설정 화면 → 친구 화면 진입점 추가
- [x] 위젯 테스트: 11개 시나리오 (`2279e81 test(friends): FriendsView 시나리오 테스트 11건`)

---

## Step 4: 친구 상세 화면 (오늘 dailyShare)

**커밋**: `f46760c feat(F15-5-4): 친구 1명의 오늘 dailyShare 상세 화면`

- [x] `lib/features/friends/views/friend_detail_view.dart` (1차)
  - 친구의 오늘 `dailyShare` 표시 (진행률 + routineSummary)
- [x] 시나리오 테스트 7건 (`19de1ea`)

---

## Step 5: Firestore Security Rules — 친구 전용 모델

**커밋**: `96364b2 feat(F15-5-5): Firestore Security Rules — 친구 전용 모델`

- [x] `firestore.rules` 작성
  - `isFriend(uid, target)` — friendship 문서 조회 helper
  - `/users/{uid}` — read: 본인 + 친구
  - `/dailyShares/{shareId}` — read: 본인 + 친구
  - `/friendships/{id}` — read/write: 본인이 from/to 인 경우만
- [x] 친구 코드 조회 (`findUidByFriendCode`) 를 위한 read 권한 정책 정리

---

## Step 6: 친구 상세 화면 보강 — 전체 루틴 리스트

**커밋**:
- `5d64b01 fix(friends): findUidByFriendCode 가 하이픈 정규화로 doc 못 찾던 버그`
- `585dc66 feat(friends): 친구 상세 화면에 친구의 전체 루틴 리스트 표시`

기존 FriendDetailView 의 한계 (친구가 토글 안 했으면 빈 화면) 를 보강.

- [x] 친구의 전체 루틴 리스트 표시 (`/users/{friendUid}/routines/` 직접 fetch)
- [x] 루틴별 오늘 완료 상태는 `dailyShare.routines` 와 join (name 일치)
- [x] 활성 요일 표시 (매일 / 월 화 수 …)
- [x] 진행률 카드 (% / 완료/총 / 진행률 바)
- [x] `firestore.rules` 확장
  - `/users/{uid}/routines/{rid}` — read: 본인 + 친구
  - `/users/{uid}/categories/{cid}` — read: 본인 + 친구
  - `/users/{uid}/dailyRecords/{date}` — read: 본인 + 친구
  - `/users/{uid}/tasks/{tid}` — 본인 only (개인 TODO 비공개)
- [x] 친구 코드 정규화 버그 수정 (사용자가 하이픈 빼고 입력해도 동작)

---

## 데이터 흐름

```
A 의 친구 코드 → B 가 입력 → friendships/{A}_{B} 생성
   ↓
B 의 친구 화면 → friendships 스트림 → A 의 프로필/dailyShare 표시
   ↓
A 의 상세 화면 진입 → A 의 routines + dailyShare 페치 (friend read 허용)
```

---

## 완료 조건

- [x] 친구 코드 발급 + 친구 추가 동작
- [x] 친구 목록 화면 (오늘 진행률 미리보기)
- [x] 친구 상세 화면 (등록 루틴 + 오늘 완료 여부 + 활성 요일)
- [x] Firestore Security Rules: 비친구는 read 차단
- [x] 위젯 테스트 25개 통과 (FriendsView 11 + FriendDetailView 7 + 기타)
- [x] 사용자 검토 및 승인 (멀티 계정 페어링 테스트 완료)

---

## 후속 작업 / 알려진 이슈

- 친구 추가가 즉시 반영 (별도 승인 흐름 없음) — 추후 양방향 승인이 필요하면 분리
- 친구의 streak / 주간 진행률은 미구현 (현재 오늘만)
- 응원/이모지/메시지 등의 상호작용은 미구현
- 친구 차단/삭제는 미구현 (friendships 문서 수동 삭제만 가능)
