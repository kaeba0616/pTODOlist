// Cloudflare Worker 진입점 — 실제 의존성 조립
// 시크릿: SERVICE_ACCOUNT_JSON (Firebase 서비스 계정 키 JSON 전체)
// 변수: FIREBASE_PROJECT_ID (wrangler.toml)
import { handleNotify } from './handler.js';
import { verifyFirebaseIdToken, getGoogleAccessToken } from './jwt.js';
import { firestoreClient } from './firestore.js';
import { fcmClient } from './fcm.js';

const JWKS_URL =
  'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';
const SCOPES = [
  'https://www.googleapis.com/auth/datastore',
  'https://www.googleapis.com/auth/firebase.messaging',
];

// isolate 재사용 동안 캐시 (Workers 는 요청 간 모듈 스코프가 유지될 수 있음)
let cachedJwks = null;
let cachedJwksAt = 0;
let cachedAccess = null;
let cachedAccessUntil = 0;

async function fetchJwks() {
  const now = Date.now();
  if (cachedJwks && now - cachedJwksAt < 60 * 60 * 1000) return cachedJwks;
  const res = await fetch(JWKS_URL);
  if (!res.ok) throw new Error(`jwks fetch failed: ${res.status}`);
  cachedJwks = await res.json();
  cachedJwksAt = now;
  return cachedJwks;
}

function accessTokenProvider(env) {
  return async () => {
    const now = Date.now();
    if (cachedAccess && now < cachedAccessUntil) return cachedAccess;
    const serviceAccount = JSON.parse(env.SERVICE_ACCOUNT_JSON);
    const { accessToken, expiresIn } = await getGoogleAccessToken({
      serviceAccount,
      scopes: SCOPES,
      fetchFn: fetch,
    });
    cachedAccess = accessToken;
    cachedAccessUntil = now + (expiresIn - 300) * 1000; // 5분 여유
    return accessToken;
  };
}

export default {
  async fetch(request, env) {
    const projectId = env.FIREBASE_PROJECT_ID;
    const getAccessToken = accessTokenProvider(env);
    const fs = firestoreClient({ projectId, getAccessToken });
    const fcm = fcmClient({ projectId, getAccessToken });

    try {
      return await handleNotify(request, {
        verifyToken: (idToken) =>
          verifyFirebaseIdToken(idToken, { projectId, fetchJwks }),
        fs,
        sendPush: fcm.sendPush,
      });
    } catch (e) {
      console.log(`[relay] error: ${e}`);
      return new Response(JSON.stringify({ error: 'internal' }), {
        status: 500,
        headers: { 'content-type': 'application/json' },
      });
    }
  },
};
