# F15: 클라우드 계정 + 데이터 동기화

- **Feature ID**: F15
- **예상 기간**: 7~10일 (실 소요: ~10일)
- **상태**: `[status: completed]`
- **의존성**: Phase 5 완료

## 개요

Google 계정으로 로그인하고 로컬 Hive 데이터를 Firebase Firestore 에 동기화한다.
앱을 재설치하거나 다른 기기에서 로그인해도 본인 데이터 (루틴/카테고리/일일기록/할일/dailyShare)
가 그대로 복원되도록 한다.

**핵심 가치**:
- 기기 변경/재설치에도 데이터 유지
- 다른 기기에서도 같은 데이터 사용 (멀티 디바이스)
- 친구 공유 (F16) 의 인프라

**아키텍처 결정**:
- 로컬 우선이 아닌 **cloud-first**: Firestore 가 SoT, Hive 는 캐시
- 로그인 시 풀 Pull → 로컬 wipe-then-fill, 로그아웃 시 로컬 wipe
- 변경 발생 시 `await push` 로 Firestore 쓰기 보장 (silent fail 방지)
- `appSyncTick` 이벤트로 모든 뷰가 sync 완료 후 자동 새로고침

---

## Step 1: Firebase 인프라 + Android 통합

**커밋**: `846a48a feat(F15): Step 2 — Firebase Android 통합 + 의존성 추가`

- [x] Firebase 프로젝트 생성 + Android 앱 등록
- [x] `google-services.json` 추가 (gitignore 처리)
- [x] `pubspec.yaml` 의존성 추가
  - `firebase_core`, `firebase_auth`, `cloud_firestore`
  - `google_sign_in`
- [x] `android/build.gradle`, `android/app/build.gradle` 플러그인 설정
- [x] `Firebase.initializeApp()` in `main.dart`

---

## Step 2: Google 로그인 + 계정 섹션

**커밋**: `279d44f feat(F15): Step 3 — Google 로그인 + 계정 섹션 추가`

- [x] `lib/features/auth/` 모듈 생성
  - `services/auth_service.dart` — signIn / signOut / authStateChanges
  - `providers/auth_providers.dart` — Riverpod
  - `views/account_section.dart` — 설정 화면 진입점
- [x] 비로그인 상태: "Google 로 로그인" 버튼
- [x] 로그인 상태: 이메일/사진/로그아웃 버튼

---

## Step 3: 사용자 프로필 (닉네임 + publicMode)

**커밋**: `e35c326 feat(F15): Step 4 — 사용자 프로필 (닉네임 + 공개모드)`

- [x] `lib/features/profile/` 모듈 생성
  - `models/user_profile.dart` (freezed)
  - `repos/user_profile_repo.dart` — Firestore `/users/{uid}` CRUD
  - `providers/profile_providers.dart`
  - `views/profile_section.dart`
- [x] 필드: `nickname`, `publicMode` (none/friends), `friendCode`
- [x] Firestore 경로: `/users/{uid}`

> 참고: F16 (친구) Step 1 에서 `publicMode` 가 단순화되고 `friendCode` 자동 발급됨.

---

## Step 4: 로컬 → Firestore 단방향 동기화

**커밋**: `01e7eba feat(F15): Step 5 — 로컬 → Firestore 단방향 동기화`

- [x] `lib/features/social/` 도메인 생성
  - `models/daily_share.dart` — 오늘의 진행률 공유용 (routines 요약 + percent)
  - `repos/daily_share_repo.dart` — Firestore `/dailyShares/{uid}_{date}`
  - `services/daily_share_sync_service.dart` — Hive 이벤트 → Firestore push
- [x] 푸시 트리거 포인트
  - 루틴 토글
  - 할 일 토글
  - 자정 리셋
- [x] `publicMode=friends` 일 때만 푸시 (개인 모드는 푸시 안 함)
- [x] 단위 테스트: `DailyShareSyncService` 5개 분기 케이스
  - 커밋: `f715365`, `e0f331c` (SnackBar 디버깅)

---

## Step 5: Cloud-first 전환 (전체 데이터 동기화)

**커밋**:
- `54ef7a4 feat(F15-7): Cloud Sync — 로그인 시 본인 데이터 fetch, 로그아웃 시 wipe`
- `59f3b1e debug(sync): 강제 동기화 버튼 + ForcePushResult — silent fail 진단`
- `bdb996d feat(F15-7): cloud-first 전환 — push 를 await + 자동 마이그레이션`
- `22d3563 feat(sync): 글로벌 sync tick 으로 모든 페이지 자동 새로고침`

dailyShare 만 동기화하던 것을 **전체 사용자 데이터**로 확장.

- [x] `lib/features/sync/services/cloud_sync_service.dart` 생성
  - `fullCloudPull(uid)` — Firestore → Hive wipe-then-fill
  - `wipeLocalForLogout()` — 로그아웃 시 로컬 데이터 삭제
- [x] Firestore 동기화 대상 컬렉션 (`/users/{uid}/...`)
  - `routines/`
  - `categories/`
  - `dailyRecords/`
  - `tasks/`
- [x] 로그인 트리거: `authStateChanges` 에서 `fullCloudPull` 호출
- [x] 푸시 await 처리: 모든 Hive 쓰기 후 Firestore push 까지 await
  - 자동 마이그레이션: 기존 로컬 데이터를 첫 로그인 시 Firestore 로 일괄 푸시
- [x] `lib/core/sync/app_sync_tick.dart` — ValueNotifier 전역 sync tick
  - sync 완료 시 `notifySyncCompleted()` 호출
  - 모든 뷰 (home/category/calendar/stats) 가 listen → 자동 refresh
- [x] 설정 화면에 "강제 동기화" 버튼 + `ForcePushResult` 진단

---

## 데이터 모델 (Firestore)

```
/users/{uid}                            # 프로필 (nickname, publicMode, friendCode)
/users/{uid}/routines/{routineId}       # 루틴
/users/{uid}/categories/{categoryId}    # 카테고리
/users/{uid}/dailyRecords/{date}        # 일일 기록
/users/{uid}/tasks/{taskId}             # 할 일 (개인, 친구 공유 X)
/dailyShares/{uid}_{date}               # 친구 공유용 진행률 요약 (F16 에서 활용)
```

---

## 비용 (Firebase Spark 무료 한도)

- Reads: 50,000/일 → 활성 사용자 ~125명까지 무료
- Writes: 20,000/일 → ~1,000명까지 무료
- Storage: 1 GiB → 사용자 1명당 ~50KB 라 거의 무한대
- Auth: 무제한 무료

**현재 (개인 + 친구 몇 명)**: 완전 무료.

---

## 완료 조건

- [x] Google 로그인 / 로그아웃 정상 동작
- [x] 로그인 시 전체 데이터 Firestore → Hive pull
- [x] 로그아웃 시 로컬 wipe
- [x] 자동 마이그레이션 (기존 로컬 → Firestore 첫 푸시)
- [x] 글로벌 sync tick 으로 모든 페이지 자동 새로고침
- [x] DailyShareSyncService 단위 테스트 통과 (5개)
- [x] 사용자 검토 및 승인 (멀티 디바이스 시나리오 테스트 완료)

---

## 후속 작업 / 알려진 이슈

- iOS Firebase 통합은 미구현 (현재 Android 만)
- 양방향 실시간 동기화 (변경 감지) 는 미구현 — 로그인 시점 풀 Pull + 변경 시 푸시
- 충돌 해결: Last-write-wins (현재로선 단일 사용자 멀티 디바이스가 주 시나리오라 OK)
