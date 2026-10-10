# F17: 친구 기능 제거 + Play Store 배포 준비

- **Feature ID**: F17
- **예상 기간**: 2~3일
- **상태**: `[status: in-progress]`
- **의존성**: Phase 6 완료

## 개요

첫 스토어 배포 범위를 "개인 사용 + Google 로그인 클라우드 백업" 으로 한정한다.
F16(친구 공유)과 FCM 푸시 릴레이는 코드에서 제거하고, Firestore 규칙은
본인 데이터만 허용하도록 축소한다. 이후 Android App Bundle 을 서명해 Play Console 에 올린다.

**유지되는 것**: F15 클라우드 동기화 전체 (Google 로그인, `users/{uid}` 하위 4개 컬렉션 sync, 강제 동기화)

**제거되는 것**: 친구 목록/상세, 친구 코드, 공개 범위(publicMode), 오늘 진행률 공유(dailyShares), FCM 토큰 등록, Cloudflare 푸시 릴레이

---

## Step 1: 코드 제거 (TDD)

- [x] 삭제: `lib/features/{friends,social,push}`, `lib/core/push`, `lib/core/utils/friend_code_generator.dart`, `push-relay/`, 해당 테스트 10개
- [x] `main.dart`: FCM 토큰 서비스 생성/등록 제거
- [x] `auth_service.dart` / `auth_providers.dart`: `PushTokenService` 의존 제거
- [x] `home_view.dart`: `dailyShareSyncService` 호출 제거 (로컬 저장만 유지)
- [x] `settings_view.dart`: 친구 메뉴 제거, 계정 부제목을 이메일로 교체
- [x] `profile/`: `friendCode`, `PublicMode` 제거 (구버전 문서 필드는 `fromMap` 에서 무시)
- [x] `pubspec.yaml`: `firebase_messaging`, `http` 제거
- [x] RED → GREEN: `test/features/profile/models/user_profile_test.dart` (신규 3개), `auth_service_signout_test.dart` 재작성
- [x] `flutter analyze` 에러 0, `flutter test` 152개 통과

## Step 2: Firestore 규칙 축소 (TDD)

- [x] RED: `firestore-tests/rules.test.mjs` 를 개인 전용 시나리오 28개로 재작성 → 기존 규칙에서 9개 실패 확인
- [x] GREEN: `firestore.rules` 를 `users/{uid}` + 4개 하위 컬렉션 본인 전용으로 축소 → 28개 통과
- [ ] 배포: `firebase deploy --only firestore:rules --project ptodolist`

## Step 3: 릴리스 빌드 설정

- [x] 앱 이름 "하루나무" (`AndroidManifest.xml`, iOS `Info.plist`)
- [x] 업로드 키스토어 생성 (`android/upload-keystore.jks`, RSA 2048, 10000일)
- [x] `android/key.properties` 생성 (gitignore) + `build.gradle.kts` 에서 읽어 release 서명
- [x] `flutter build appbundle --release` 성공

## Step 4: Play Console 등록 (수동)

`docs/ops/deploy-guide.md` 참조.

- [ ] 앱 생성 (하루나무, 무료, 앱)
- [ ] 내부 테스트 트랙에 `.aab` 업로드
- [ ] Play App Signing 의 SHA-1 을 Firebase 콘솔 Android 앱에 추가 → Google 로그인 확인
- [ ] 개인정보처리방침 URL 등록 (`docs/legal/privacy-policy.md` 를 공개 URL 로 호스팅)
- [ ] 데이터 보안 양식, 스토어 등록정보(스크린샷, 설명), 콘텐츠 등급 작성

---

## 복구 메모

친구 기능을 되살릴 때 기준 커밋: `53f0ce9` (Cloud Functions → Cloudflare Worker 릴레이 전환).
`git checkout 53f0ce9 -- ptodolist_front/lib/features/friends ...` 로 디렉토리 단위 복구 가능하며,
`firestore.rules` 도 같은 커밋의 버전을 참고한다.
