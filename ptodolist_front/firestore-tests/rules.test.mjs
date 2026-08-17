// Firestore 보안 규칙 테스트
// 실행: npm test (firebase emulators:exec 로 에뮬레이터 안에서 node --test 실행)
//
// 시드 상황:
//   alice ↔ bob   친구 (publicMode: friends)
//   bob   ↔ dave  친구 (dave 는 publicMode: off)
//   carol         아무와도 친구 아님, bob 에게 요청만 보낸 상태
import { before, after, describe, it } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, getDocs, setDoc, updateDoc, deleteDoc, collection, query, where } from 'firebase/firestore';

let env;

const ALICE = 'alice';
const BOB = 'bob';
const CAROL = 'carol';
const DAVE = 'dave';

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
    const profile = (uid, publicMode) => ({
      uid, nickname: uid, friendCode: `${uid.toUpperCase()}-CODE`, publicMode,
    });
    await setDoc(doc(f, 'users', ALICE), profile(ALICE, 'friends'));
    await setDoc(doc(f, 'users', BOB), profile(BOB, 'friends'));
    await setDoc(doc(f, 'users', CAROL), profile(CAROL, 'friends'));
    await setDoc(doc(f, 'users', DAVE), profile(DAVE, 'off'));

    await setDoc(doc(f, 'friendships', 'alice_bob'), { members: [ALICE, BOB] });
    await setDoc(doc(f, 'friendships', 'bob_dave'), { members: [BOB, DAVE] });

    await setDoc(doc(f, 'users', ALICE, 'routines', 'r1'), { title: '물마시기' });
    await setDoc(doc(f, 'users', ALICE, 'categories', 'c1'), { name: '건강' });
    await setDoc(doc(f, 'users', ALICE, 'tasks', 't1'), { title: '세금신고' });
    await setDoc(doc(f, 'users', ALICE, 'dailyRecords', '2026-08-17'), { done: 3 });
    await setDoc(doc(f, 'users', DAVE, 'routines', 'r1'), { title: '비밀루틴' });
    await setDoc(doc(f, 'users', DAVE, 'dailyRecords', '2026-08-17'), { done: 1 });
    await setDoc(doc(f, 'users', ALICE, 'fcmTokens', 'tok-alice'), { platform: 'android' });

    await setDoc(doc(f, 'friendCodes', 'AAAA-BBBB'), { uid: ALICE });

    await setDoc(doc(f, 'dailyShares', 'share-alice'), { uid: ALICE, rate: 0.8 });
    await setDoc(doc(f, 'dailyShares', 'share-dave'), { uid: DAVE, rate: 0.5 });

    // carol → bob 에게 보낸 대기중 요청
    await setDoc(doc(f, 'friendRequests', BOB, 'incoming', CAROL), {
      fromUid: CAROL, fromNickname: 'carol', fromCode: 'CAROL-CODE',
    });
  });
});

after(async () => {
  await env.cleanup();
});

describe('users 프로필', () => {
  it('본인은 자기 프로필을 읽는다', () =>
    assertSucceeds(getDoc(doc(db(ALICE), 'users', ALICE))));
  it('친구는 프로필을 읽는다', () =>
    assertSucceeds(getDoc(doc(db(BOB), 'users', ALICE))));
  it('타인(비친구)은 프로필을 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(CAROL), 'users', ALICE))));
  it('비로그인은 프로필을 읽을 수 없다', () =>
    assertFails(getDoc(doc(anonDb(), 'users', ALICE))));
  it('본인은 자기 프로필을 쓴다', () =>
    assertSucceeds(setDoc(doc(db(ALICE), 'users', ALICE), { uid: ALICE, nickname: 'a2', publicMode: 'friends' })));
  it('타인은 프로필을 쓸 수 없다', () =>
    assertFails(setDoc(doc(db(CAROL), 'users', ALICE), { nickname: 'hack' })));
});

describe('friendships', () => {
  it('멤버는 자기 friendship 을 읽는다', () =>
    assertSucceeds(getDoc(doc(db(ALICE), 'friendships', 'alice_bob'))));
  it('제3자는 남의 friendship 을 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(CAROL), 'friendships', 'alice_bob'))));
  it('내 친구 목록 쿼리(arrayContains 본인)는 허용된다', () =>
    assertSucceeds(getDocs(query(
      collection(db(CAROL), 'friendships'),
      where('members', 'array-contains', CAROL),
    ))));
  it('요청 없이 일방적으로 friendship 을 만들 수 없다 (강제 친구 차단)', () =>
    assertFails(setDoc(doc(db(CAROL), 'friendships', 'alice_carol'), {
      members: [ALICE, CAROL], acceptedBy: CAROL,
    })));
  it('받은 요청이 있으면 수락자가 friendship 을 만든다', () =>
    assertSucceeds(setDoc(doc(db(BOB), 'friendships', 'bob_carol'), {
      members: [BOB, CAROL], acceptedBy: BOB, createdAt: '2026-08-17',
    })));
  it('요청을 보낸 쪽이 스스로 수락할 수 없다', () =>
    assertFails(setDoc(doc(db(CAROL), 'friendships', 'bob_carol2'), {
      members: [BOB, CAROL], acceptedBy: CAROL,
    })));
  it('acceptedBy 는 본인이어야 한다', () =>
    assertFails(setDoc(doc(db(BOB), 'friendships', 'bob_carol3'), {
      members: [BOB, CAROL], acceptedBy: CAROL,
    })));
  it('friendship 은 수정 불가(불변)', () =>
    assertFails(updateDoc(doc(db(BOB), 'friendships', 'alice_bob'), {
      members: [BOB, CAROL],
    })));
  it('멤버는 친구를 끊을 수 있다(삭제)', () =>
    assertSucceeds(deleteDoc(doc(db(ALICE), 'friendships', 'alice_bob'))
      .then(() => env.withSecurityRulesDisabled(async (ctx) =>
        // 다음 테스트를 위해 원복
        setDoc(doc(ctx.firestore(), 'friendships', 'alice_bob'), { members: [ALICE, BOB] })))));
  it('제3자는 남의 friendship 을 삭제할 수 없다', () =>
    assertFails(deleteDoc(doc(db(CAROL), 'friendships', 'alice_bob'))));
});

describe('공유 데이터 (routines/categories/dailyRecords)', () => {
  it('친구는 공개(friends) 사용자의 루틴을 읽는다', () =>
    assertSucceeds(getDoc(doc(db(BOB), 'users', ALICE, 'routines', 'r1'))));
  it('친구는 공개 사용자의 카테고리를 읽는다', () =>
    assertSucceeds(getDoc(doc(db(BOB), 'users', ALICE, 'categories', 'c1'))));
  it('친구는 공개 사용자의 일일기록을 읽는다', () =>
    assertSucceeds(getDoc(doc(db(BOB), 'users', ALICE, 'dailyRecords', '2026-08-17'))));
  it('비친구는 루틴을 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(CAROL), 'users', ALICE, 'routines', 'r1'))));
  it('publicMode:off 면 친구라도 루틴을 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(BOB), 'users', DAVE, 'routines', 'r1'))));
  it('publicMode:off 면 친구라도 일일기록을 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(BOB), 'users', DAVE, 'dailyRecords', '2026-08-17'))));
  it('본인은 publicMode 와 무관하게 자기 루틴을 읽는다', () =>
    assertSucceeds(getDoc(doc(db(DAVE), 'users', DAVE, 'routines', 'r1'))));
  it('tasks 는 친구여도 읽을 수 없다(본인 전용)', () =>
    assertFails(getDoc(doc(db(BOB), 'users', ALICE, 'tasks', 't1'))));
  it('타인은 남의 루틴을 쓸 수 없다', () =>
    assertFails(setDoc(doc(db(BOB), 'users', ALICE, 'routines', 'r2'), { title: 'x' })));
});

describe('dailyShares', () => {
  it('친구는 공개(friends) 사용자의 공유 카드를 읽는다', () =>
    assertSucceeds(getDoc(doc(db(BOB), 'dailyShares', 'share-alice'))));
  it('publicMode:off 면 친구라도 공유 카드를 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(BOB), 'dailyShares', 'share-dave'))));
  it('본인은 publicMode 와 무관하게 자기 공유 카드를 읽는다', () =>
    assertSucceeds(getDoc(doc(db(DAVE), 'dailyShares', 'share-dave'))));
  it('비친구는 공유 카드를 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(CAROL), 'dailyShares', 'share-alice'))));
});

describe('friendCodes', () => {
  it('로그인 사용자는 코드→uid 조회 가능', () =>
    assertSucceeds(getDoc(doc(db(CAROL), 'friendCodes', 'AAAA-BBBB'))));
  it('본인 uid 로 코드 등록 가능', () =>
    assertSucceeds(setDoc(doc(db(CAROL), 'friendCodes', 'CCCC-DDDD'), {
      uid: CAROL, createdAt: '2026-08-17',
    })));
  it('남의 uid 로 코드 등록 불가', () =>
    assertFails(setDoc(doc(db(CAROL), 'friendCodes', 'EEEE-FFFF'), { uid: ALICE })));
  it('코드 수정 불가', () =>
    assertFails(updateDoc(doc(db(ALICE), 'friendCodes', 'AAAA-BBBB'), { uid: BOB })));
});

describe('friendRequests', () => {
  it('요청 생성: 보낸 사람 본인 명의로만 가능', () =>
    assertSucceeds(setDoc(doc(db(CAROL), 'friendRequests', ALICE, 'incoming', CAROL), {
      fromUid: CAROL, fromNickname: 'carol', fromCode: 'CAROL-CODE',
    })));
  it('요청 생성: 타인 명의 사칭 불가', () =>
    assertFails(setDoc(doc(db(CAROL), 'friendRequests', ALICE, 'incoming', BOB), {
      fromUid: BOB,
    })));
  it('받은 사람은 자기 수신함을 읽는다', () =>
    assertSucceeds(getDoc(doc(db(BOB), 'friendRequests', BOB, 'incoming', CAROL))));
  it('타인은 남의 수신함을 읽을 수 없다', () =>
    assertFails(getDoc(doc(db(ALICE), 'friendRequests', BOB, 'incoming', CAROL))));
});

describe('fcmTokens (푸시 토큰)', () => {
  it('본인은 자기 토큰을 등록한다', () =>
    assertSucceeds(setDoc(doc(db(ALICE), 'users', ALICE, 'fcmTokens', 'tok-new'), {
      platform: 'android', updatedAt: '2026-08-17',
    })));
  it('본인은 자기 토큰을 삭제한다', () =>
    assertSucceeds(deleteDoc(doc(db(ALICE), 'users', ALICE, 'fcmTokens', 'tok-new'))));
  it('타인은 내 토큰을 쓸 수 없다', () =>
    assertFails(setDoc(doc(db(BOB), 'users', ALICE, 'fcmTokens', 'tok-evil'), { platform: 'x' })));
  it('타인은 내 토큰을 읽을 수 없다 (친구여도)', () =>
    assertFails(getDoc(doc(db(BOB), 'users', ALICE, 'fcmTokens', 'tok-alice'))));
});
