# 배포 가이드 — Google Play (하루나무)

Android 전용. iOS 는 현재 범위 밖.

## 0. 사전 준비 (1회)

| 항목 | 위치 | 비고 |
|---|---|---|
| 업로드 키스토어 | `ptodolist_front/android/upload-keystore.jks` | gitignore. **반드시 안전한 곳에 백업** (분실 시 Play 에서 업로드 키 재설정 요청 필요) |
| 서명 비밀번호 | `ptodolist_front/android/key.properties` | gitignore. 키스토어와 함께 백업 |
| Firebase 설정 | `ptodolist_front/android/app/google-services.json` | gitignore. Firebase 콘솔에서 재다운로드 가능 |
| Firebase 프로젝트 | `ptodolist` | Firestore + Auth(Google) |

`key.properties` 형식:
```
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=upload-keystore.jks
```
파일이 없으면 `build.gradle.kts` 가 debug 키로 폴백하므로, 스토어 업로드 전에 꼭 존재해야 한다.

## 1. 버전 올리기

`ptodolist_front/pubspec.yaml` 의 `version: X.Y.Z+N` 에서
- `X.Y.Z` = 사용자에게 보이는 버전 (versionName)
- `N` = Play 에 올릴 때마다 **반드시 증가** (versionCode)

## 2. 검증

```bash
cd ptodolist_front
flutter analyze                 # 에러 0
flutter test                    # 전부 통과
cd firestore-tests && npm test  # 규칙 테스트 (Firebase 에뮬레이터 자동 기동)
```

## 3. Firestore 규칙 배포

규칙(`ptodolist_front/firestore.rules`)이 바뀐 릴리스라면 앱보다 **먼저** 배포한다.

```bash
cd ptodolist_front
npx --prefix firestore-tests firebase login          # 최초 1회
npx --prefix firestore-tests firebase deploy --only firestore:rules --project ptodolist
```

## 4. App Bundle 빌드

```bash
cd ptodolist_front
flutter build appbundle --release
# 결과: build/app/outputs/bundle/release/app-release.aab
```

서명 확인 (업로드 키로 서명됐는지):
```bash
/usr/lib/jvm/java-17-openjdk-amd64/bin/keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab | grep SHA1
```
`android/upload-keystore.jks` 의 SHA1 과 같아야 한다.

## 5. Play Console (최초 등록)

1. **앱 만들기**: 이름 "하루나무", 기본 언어 한국어, 앱, 무료.
2. **앱 설정 대시보드** 체크리스트:
   - 개인정보처리방침 URL: `docs/legal/privacy-policy.md` 내용을 공개 URL 로 호스팅 (GitHub Pages 등) 후 입력
   - 앱 액세스 권한: "모든 기능을 제한 없이 사용 가능" (로그인 없이도 동작)
   - 광고: 없음
   - 콘텐츠 등급: 설문 작성 (유틸리티/생산성)
   - 타겟층: 18세 이상 권장 (아동 대상 아님)
   - 데이터 보안: 아래 표 참고
   - 앱 카테고리: 생산성
3. **스토어 등록정보**: 짧은 설명(80자), 긴 설명, 아이콘 512×512, 그래픽 이미지 1024×500, 휴대전화 스크린샷 2장 이상.
4. **테스트 → 내부 테스트** 에서 새 버전 만들기 → `app-release.aab` 업로드 → 테스터 이메일 목록 추가 → 저장/검토/출시.
5. **Play App Signing** 이 기본 활성화됨. 업로드 후 *설정 → 앱 무결성* 에서 **앱 서명 키 인증서의 SHA-1** 을 복사.

## 6. Firebase 에 Play 서명 SHA-1 등록 (Google 로그인 필수)

Play 가 최종 APK 를 **자체 키**로 다시 서명하므로, 그 키의 SHA-1 을 Firebase 가 알아야 Google 로그인이 된다.

1. Firebase 콘솔 → 프로젝트 설정 → 내 앱 → Android (`com.ptodolist.ptodolist`) → **디지털 지문 추가**
2. 5단계에서 복사한 **앱 서명 키 SHA-1** 추가 (업로드 키 SHA-1 도 함께 추가해 두면 로컬 release 빌드 테스트에 유용)
3. `google-services.json` 을 다시 다운로드해 `android/app/` 에 교체 (OAuth client 항목이 추가됨)
4. 다음 빌드부터 반영. 이미 올린 AAB 는 교체 불필요 (SHA-1 은 서버측 검증)

## 7. 데이터 보안 양식 (참고값)

| 수집 데이터 | 수집 여부 | 용도 | 비고 |
|---|---|---|---|
| 이메일, 이름, 프로필 사진 | 수집 (선택) | 계정 관리 | Google 로그인 시에만 |
| 앱 활동 (루틴/할 일/일일 기록) | 수집 (선택) | 앱 기능 (클라우드 백업) | 로그인 시에만 Firestore 에 저장 |
| 기기 ID, 위치, 연락처, 광고 ID | 수집 안 함 | — | |

- 전송 중 암호화: 예 (HTTPS)
- 삭제 요청: 앱 내 로그아웃 시 로컬 삭제, 계정 데이터는 개인정보처리방침의 문의처로 요청

## 8. 프로덕션 승격

내부 테스트에서 로그인 → 데이터 입력 → 재설치 후 복원까지 확인한 뒤,
**프로덕션 → 새 버전 만들기** 에서 같은 AAB 를 선택해 출시. 첫 프로덕션 심사는 수일 걸릴 수 있다.

## 롤백

Play Console 은 이전 버전으로 되돌릴 수 없다. 문제 시 versionCode 를 올린 수정 버전을 다시 올린다.
Firestore 규칙은 `git checkout <이전 커밋> -- ptodolist_front/firestore.rules` 후 3단계로 재배포.
