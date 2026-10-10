# Phase 8: Play Store Release (개인 전용)

**목표**: 친구 공유 기능을 제외한 "개인 + 클라우드 백업" 구성으로
Google Play Store 에 첫 배포 (앱 이름: **하루나무**)

**상태**: `[status: in-progress]`

---

## 배경

Phase 6 까지 친구 공유(F16)와 FCM 푸시 릴레이까지 구현했지만, 첫 스토어 배포는
리뷰 범위와 운영 부담을 줄이기 위해 **개인 사용 + Google 로그인 클라우드 백업**만
포함한다. 친구 기능은 코드에서 완전히 제거하고(git 이력에 보존), 필요해지면
커밋 `53f0ce9` 기준으로 복구한다.

---

## 핵심 결정 (브레인스토밍 합의, 2026-10-10)

| 항목 | 결정 |
|---|---|
| 친구/소셜/푸시 코드 | **완전 삭제** (플래그 게이팅 아님) |
| Firestore 규칙 | **개인 전용으로 축소** (본인 uid 외 전부 deny) |
| 앱 표시 이름 | **하루나무** (패키지명 `com.ptodolist.ptodolist` 유지) |
| 릴리스 서명 | 업로드 키스토어 `android/upload-keystore.jks` + `key.properties` (gitignore) |

---

## Features

| ID | 기능 | 의존성 | 상태 |
|---|---|---|---|
| F17 | 친구 기능 제거 + Play Store 배포 준비 | Phase 6 완료 | `[status: in-progress]` |

상세 계획: [`f17-play-release.md`](../features/f17-play-release.md)

---

## 완료 조건

- [x] friends / social / push 모듈 + push-relay Worker 삭제, 테스트 152개 통과
- [x] Firestore 규칙 개인 전용 축소 + 규칙 테스트 28개 통과
- [x] 앱 이름 "하루나무", 릴리스 서명 설정, `flutter build appbundle --release` 성공
- [ ] Firestore 규칙 배포 (`firebase deploy --only firestore:rules`)
- [ ] Play Console 앱 등록 + 내부 테스트 트랙 업로드 (수동, `docs/ops/deploy-guide.md`)
- [ ] Play App Signing SHA-1 을 Firebase 에 등록 (Google 로그인 동작 확인)
