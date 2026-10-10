// Firestore 보안 규칙 테스트 (개인 전용 모델)
// 실행: npm test (firebase emulators:exec 로 에뮬레이터 안에서 node --test 실행)
//
// 시드 상황:
//   alice, bob  — 각자 로그인 사용자. 서로 아무 관계 없음.
//   레거시 컬렉션(friendships/friendCodes/dailyShares/fcmTokens/friendRequests) 은
//   구버전 앱이 남긴 데이터가 있어도 아무도 접근할 수 없어야 한다.
import { before, after, describe, it } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, getDocs, setDoc, updateDoc, deleteDoc, collection } from 'firebase/firestore';

let env;

const ALICE = 'alice';
const BOB = 'bob';

const db = (uid) => env.authenticatedContext(uid).firestore();
const anonDb = () => env.unauthenticatedContext().firestore();

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'ptodolist',
    firestore: {
      rules: readFileSync('../firestore.rules', 'utf8'),
      host: '127.0.0.1',
      port: 8425,
    },
  });
  await env.withSecurityRulesDisabled(async (ctx) => {
    const f = ctx.firestore();
    await setDoc(doc(f, 'users', ALICE), { uid: ALICE, nickname: 'alice' });
    await setDoc(doc(f, 'users', BOB), { uid: BOB, nickname: 'bob' });

    await setDoc(doc(f, 'users', ALICE, 'routines', 'r1'), { title: '물마시기' });
    await setDoc(doc(f, 'users', ALICE, 'categories', 'c1'), { name: '건강' });
    await setDoc(doc(f, 'users', ALICE, 'tasks', 't1'), { title: '세금신고' });
    await setDoc(doc(f, 'users', ALICE, 'dailyRecords', '2026-08-17'), { done: 3 });

    // 구버전(친구 기능) 앱이 남긴 레거시 데이터
    await setDoc(doc(f, 'friendships', 'alice_bob'), { members: [ALICE, BOB] });
    await setDoc(doc(f, 'friendCodes', 'AAAA-BBBB'), { uid: ALICE });
    await setDoc(doc(f, 'dailyShares', 'share-alice'), { uid: ALICE, rate: 0.8 });
    await setDoc(doc(f, 'users', ALICE, 'fcmTokens', 'tok-alice'), { platform: 'android' });
    await setDoc(doc(f, 'friendRequests', BOB, 'incoming', ALICE), { fromUid: ALICE });
  });
});

after(async () => {
  await env.cleanup();
});

describe('users 프로필', () => {
  it('본인은 자기 프로필을 읽는다', () =>
    assertSucceeds(getDoc(doc(db(ALICE), 'users', ALICE))));
  it('타인은 프로필을 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(BOB), 'users', ALICE))));
  it('비로그인은 프로필을 읽을 수 없다', () =>
    assertFails(getDoc(doc(anonDb(), 'users', ALICE))));
  it('본인은 자기 프로필을 쓴다', () =>
    assertSucceeds(setDoc(doc(db(ALICE), 'users', ALICE), { uid: ALICE, nickname: 'a2' })));
  it('타인은 프로필을 쓸 수 없다', () =>
    assertFails(setDoc(doc(db(BOB), 'users', ALICE), { nickname: 'hack' })));
});

describe('개인 데이터 (routines/categories/tasks/dailyRecords)', () => {
  it('본인은 자기 루틴을 읽는다', () =>
    assertSucceeds(getDoc(doc(db(ALICE), 'users', ALICE, 'routines', 'r1'))));
  it('본인은 자기 루틴 컬렉션을 통째로 읽는다 (풀 Pull)', () =>
    assertSucceeds(getDocs(collection(db(ALICE), 'users', ALICE, 'routines'))));
  it('본인은 자기 카테고리를 읽는다', () =>
    assertSucceeds(getDoc(doc(db(ALICE), 'users', ALICE, 'categories', 'c1'))));
  it('본인은 자기 할 일을 읽는다', () =>
    assertSucceeds(getDoc(doc(db(ALICE), 'users', ALICE, 'tasks', 't1'))));
  it('본인은 자기 일일기록을 읽는다', () =>
    assertSucceeds(getDoc(doc(db(ALICE), 'users', ALICE, 'dailyRecords', '2026-08-17'))));
  it('본인은 자기 루틴을 쓰고 지운다', async () => {
    await assertSucceeds(setDoc(doc(db(ALICE), 'users', ALICE, 'routines', 'r2'), { title: 'x' }));
    await assertSucceeds(deleteDoc(doc(db(ALICE), 'users', ALICE, 'routines', 'r2')));
  });

  it('타인은 남의 루틴을 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(BOB), 'users', ALICE, 'routines', 'r1'))));
  it('타인은 남의 카테고리를 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(BOB), 'users', ALICE, 'categories', 'c1'))));
  it('타인은 남의 할 일을 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(BOB), 'users', ALICE, 'tasks', 't1'))));
  it('타인은 남의 일일기록을 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(BOB), 'users', ALICE, 'dailyRecords', '2026-08-17'))));
  it('타인은 남의 루틴을 쓸 수 없다', () =>
    assertFails(setDoc(doc(db(BOB), 'users', ALICE, 'routines', 'r9'), { title: 'x' })));
  it('비로그인은 아무것도 읽을 수 없다', () =>
    assertFails(getDoc(doc(anonDb(), 'users', ALICE, 'routines', 'r1'))));
});

describe('레거시 친구/공유/푸시 컬렉션은 완전 봉쇄', () => {
  it('friendships 읽기 불가 (멤버여도)', () =>
    assertFails(getDoc(doc(db(ALICE), 'friendships', 'alice_bob'))));
  it('friendships 생성 불가', () =>
    assertFails(setDoc(doc(db(ALICE), 'friendships', 'alice_x'), { members: [ALICE, 'x'], acceptedBy: ALICE })));
  it('friendCodes 읽기 불가', () =>
    assertFails(getDoc(doc(db(ALICE), 'friendCodes', 'AAAA-BBBB'))));
  it('friendCodes 생성 불가', () =>
    assertFails(setDoc(doc(db(ALICE), 'friendCodes', 'ZZZZ-ZZZZ'), { uid: ALICE })));
  it('dailyShares 읽기 불가 (본인 것이어도)', () =>
    assertFails(getDoc(doc(db(ALICE), 'dailyShares', 'share-alice'))));
  it('dailyShares 생성 불가', () =>
    assertFails(setDoc(doc(db(ALICE), 'dailyShares', 'share-new'), { uid: ALICE })));
  it('fcmTokens 읽기 불가 (본인 것이어도)', () =>
    assertFails(getDoc(doc(db(ALICE), 'users', ALICE, 'fcmTokens', 'tok-alice'))));
  it('fcmTokens 생성 불가', () =>
    assertFails(setDoc(doc(db(ALICE), 'users', ALICE, 'fcmTokens', 'tok-new'), { platform: 'android' })));
  it('friendRequests 읽기 불가 (수신자여도)', () =>
    assertFails(getDoc(doc(db(BOB), 'friendRequests', BOB, 'incoming', ALICE))));
  it('friendRequests 생성 불가', () =>
    assertFails(setDoc(doc(db(ALICE), 'friendRequests', BOB, 'incoming', ALICE), { fromUid: ALICE })));
  it('legacy 문서 수정 불가', () =>
    assertFails(updateDoc(doc(db(ALICE), 'friendCodes', 'AAAA-BBBB'), { uid: BOB })));
});
