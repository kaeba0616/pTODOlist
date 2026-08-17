// 요청 처리 오케스트레이션 — 인증/조회/발송은 deps 로 주입받는 순수 로직
import {
  buildFriendRequestNotification,
  buildFriendAcceptedNotification,
} from './notifications.js';

export function makePairId(a, b) {
  return [a, b].sort().join('_');
}

function json(status, body) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}

/// deps:
///  - verifyToken(idToken) → {uid}  (실패 시 throw)
///  - fs.getDoc(path) → fields|null / fs.listCollection(path) → [docId] / fs.deleteDoc(path)
///  - sendPush({token, notification}) → {ok, unregistered}
export async function handleNotify(request, deps) {
  const url = new URL(request.url);
  if (request.method !== 'POST') return json(405, { error: 'method not allowed' });
  if (url.pathname !== '/notify/friend-request'
      && url.pathname !== '/notify/friend-accepted') {
    return json(404, { error: 'not found' });
  }

  const auth = request.headers.get('authorization') ?? '';
  if (!auth.startsWith('Bearer ')) return json(401, { error: 'missing token' });
  let caller;
  try {
    caller = (await deps.verifyToken(auth.slice('Bearer '.length))).uid;
  } catch {
    return json(401, { error: 'invalid token' });
  }

  let body;
  try {
    body = await request.json();
  } catch {
    return json(400, { error: 'invalid body' });
  }
  const toUid = body?.toUid;
  if (typeof toUid !== 'string' || toUid.length === 0 || toUid === caller) {
    return json(400, { error: 'toUid required' });
  }

  // 정당성 검증: Firestore 에 실제 사건이 존재해야만 발송 (위조 호출 차단)
  if (url.pathname === '/notify/friend-request') {
    const reqDoc = await deps.fs.getDoc(`friendRequests/${toUid}/incoming/${caller}`);
    if (!reqDoc) return json(403, { error: 'no such friend request' });
  } else {
    const pair = await deps.fs.getDoc(`friendships/${makePairId(caller, toUid)}`);
    if (!pair || pair.acceptedBy !== caller) {
      return json(403, { error: 'no such acceptance' });
    }
  }

  const callerProfile = await deps.fs.getDoc(`users/${caller}`);
  const nickname = callerProfile?.nickname ?? '';
  const notification = url.pathname === '/notify/friend-request'
      ? buildFriendRequestNotification(nickname)
      : buildFriendAcceptedNotification(nickname);

  const tokensPath = `users/${toUid}/fcmTokens`;
  const tokens = await deps.fs.listCollection(tokensPath);
  let sent = 0;
  for (const token of tokens) {
    const result = await deps.sendPush({ token, notification });
    if (result.ok) sent++;
    if (result.unregistered) {
      await deps.fs.deleteDoc(`${tokensPath}/${token}`);
    }
  }
  return json(200, { sent });
}
