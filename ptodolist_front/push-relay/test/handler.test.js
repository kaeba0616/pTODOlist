// 릴레이 핸들러 오케스트레이션 테스트 (검증/조회/발송은 fake 주입)
import { describe, it, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { handleNotify, makePairId } from '../src/handler.js';

const BASE = 'https://relay.test';

function makeDeps() {
  const calls = { pushes: [], deleted: [] };
  const docs = new Map();
  const collections = new Map();
  const deps = {
    verifyToken: async (t) => {
      if (t === 'good-token') return { uid: 'alice' };
      throw new Error('invalid token');
    },
    fs: {
      getDoc: async (path) => docs.get(path) ?? null,
      listCollection: async (path) => collections.get(path) ?? [],
      deleteDoc: async (path) => { calls.deleted.push(path); },
    },
    sendPush: async ({ token, notification }) => {
      calls.pushes.push({ token, notification });
      return { ok: !token.startsWith('dead-'), unregistered: token.startsWith('dead-') };
    },
  };
  return { deps, calls, docs, collections };
}

function req(path, { token = 'good-token', body = {} } = {}) {
  const headers = { 'content-type': 'application/json' };
  if (token != null) headers['authorization'] = `Bearer ${token}`;
  return new Request(`${BASE}${path}`, {
    method: 'POST', headers, body: JSON.stringify(body),
  });
}

describe('makePairId', () => {
  it('앱의 Friendship.makePairId 와 동일: 정렬 + 언더스코어', () => {
    assert.equal(makePairId('bob', 'alice'), 'alice_bob');
    assert.equal(makePairId('alice', 'bob'), 'alice_bob');
  });
});

describe('handleNotify 공통', () => {
  let ctx;
  beforeEach(() => { ctx = makeDeps(); });

  it('Authorization 헤더가 없으면 401', async () => {
    const res = await handleNotify(req('/notify/friend-request', { token: null, body: { toUid: 'bob' } }), ctx.deps);
    assert.equal(res.status, 401);
  });

  it('토큰 검증 실패면 401', async () => {
    const res = await handleNotify(req('/notify/friend-request', { token: 'bad', body: { toUid: 'bob' } }), ctx.deps);
    assert.equal(res.status, 401);
  });

  it('모르는 경로면 404', async () => {
    const res = await handleNotify(req('/notify/unknown', { body: { toUid: 'bob' } }), ctx.deps);
    assert.equal(res.status, 404);
  });

  it('toUid 가 없으면 400', async () => {
    const res = await handleNotify(req('/notify/friend-request', { body: {} }), ctx.deps);
    assert.equal(res.status, 400);
  });
});

describe('POST /notify/friend-request (caller=alice 가 bob 에게 요청)', () => {
  let ctx;
  beforeEach(() => {
    ctx = makeDeps();
    ctx.docs.set('users/alice', { nickname: '앨리스' });
    ctx.docs.set('friendRequests/bob/incoming/alice', { fromUid: 'alice' });
    ctx.collections.set('users/bob/fcmTokens', ['tok-1', 'tok-2']);
  });

  it('요청 문서가 실존하면 bob 의 모든 토큰으로 발송한다', async () => {
    const res = await handleNotify(req('/notify/friend-request', { body: { toUid: 'bob' } }), ctx.deps);
    assert.equal(res.status, 200);
    assert.equal((await res.json()).sent, 2);
    assert.deepEqual(ctx.calls.pushes.map((p) => p.token), ['tok-1', 'tok-2']);
    assert.equal(ctx.calls.pushes[0].notification.title, '친구 요청');
    assert.match(ctx.calls.pushes[0].notification.body, /앨리스/);
  });

  it('요청 문서가 없으면 403 — 위조 호출 차단', async () => {
    ctx.docs.delete('friendRequests/bob/incoming/alice');
    const res = await handleNotify(req('/notify/friend-request', { body: { toUid: 'bob' } }), ctx.deps);
    assert.equal(res.status, 403);
    assert.equal(ctx.calls.pushes.length, 0);
  });

  it('무효(unregistered) 토큰은 발송 후 삭제한다', async () => {
    ctx.collections.set('users/bob/fcmTokens', ['tok-1', 'dead-2']);
    await handleNotify(req('/notify/friend-request', { body: { toUid: 'bob' } }), ctx.deps);
    assert.deepEqual(ctx.calls.deleted, ['users/bob/fcmTokens/dead-2']);
  });

  it('토큰이 없으면 발송 없이 200 sent=0', async () => {
    ctx.collections.delete('users/bob/fcmTokens');
    const res = await handleNotify(req('/notify/friend-request', { body: { toUid: 'bob' } }), ctx.deps);
    assert.equal(res.status, 200);
    assert.equal((await res.json()).sent, 0);
  });
});

describe('POST /notify/friend-accepted (caller=alice 가 bob 의 요청을 수락)', () => {
  let ctx;
  beforeEach(() => {
    ctx = makeDeps();
    ctx.docs.set('users/alice', { nickname: '앨리스' });
    ctx.docs.set('friendships/alice_bob', { acceptedBy: 'alice' });
    ctx.collections.set('users/bob/fcmTokens', ['tok-b']);
  });

  it('수락자 본인 호출이면 요청 보냈던 bob 에게 발송한다', async () => {
    const res = await handleNotify(req('/notify/friend-accepted', { body: { toUid: 'bob' } }), ctx.deps);
    assert.equal(res.status, 200);
    assert.equal(ctx.calls.pushes.length, 1);
    assert.equal(ctx.calls.pushes[0].token, 'tok-b');
    assert.equal(ctx.calls.pushes[0].notification.title, '친구 수락');
    assert.match(ctx.calls.pushes[0].notification.body, /앨리스/);
  });

  it('friendship 이 없으면 403', async () => {
    ctx.docs.delete('friendships/alice_bob');
    const res = await handleNotify(req('/notify/friend-accepted', { body: { toUid: 'bob' } }), ctx.deps);
    assert.equal(res.status, 403);
  });

  it('acceptedBy 가 호출자가 아니면 403 — 상대방 명의 위조 차단', async () => {
    ctx.docs.set('friendships/alice_bob', { acceptedBy: 'bob' });
    const res = await handleNotify(req('/notify/friend-accepted', { body: { toUid: 'bob' } }), ctx.deps);
    assert.equal(res.status, 403);
    assert.equal(ctx.calls.pushes.length, 0);
  });
});
