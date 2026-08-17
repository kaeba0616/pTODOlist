// JWT 유틸 — Firebase ID 토큰 검증 + 서비스 계정 OAuth 토큰 발급 (WebCrypto)

const enc = new TextEncoder();
const dec = new TextDecoder();

export function b64urlEncodeBytes(bytes) {
  let bin = '';
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin).replaceAll('+', '-').replaceAll('/', '_').replace(/=+$/, '');
}

export function b64urlDecodeToBytes(s) {
  const b64 = s.replaceAll('-', '+').replaceAll('_', '/')
    .padEnd(s.length + ((4 - (s.length % 4)) % 4), '=');
  const bin = atob(b64);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes;
}

function decodeJsonPart(part) {
  return JSON.parse(dec.decode(b64urlDecodeToBytes(part)));
}

/// Firebase ID 토큰 검증. 성공 시 { uid } 반환, 실패 시 throw.
/// fetchJwks: () => Promise<{keys: [jwk...]}> — Google securetoken JWKS
export async function verifyFirebaseIdToken(token, { projectId, fetchJwks, nowSeconds }) {
  const now = nowSeconds ? nowSeconds() : Date.now() / 1000;
  const parts = token.split('.');
  if (parts.length !== 3) throw new Error('malformed token');
  const [headerPart, payloadPart, sigPart] = parts;
  const header = decodeJsonPart(headerPart);
  const payload = decodeJsonPart(payloadPart);

  if (header.alg !== 'RS256') throw new Error(`unexpected alg: ${header.alg}`);
  if (payload.aud !== projectId) throw new Error('aud mismatch');
  if (payload.iss !== `https://securetoken.google.com/${projectId}`) {
    throw new Error('iss mismatch');
  }
  if (typeof payload.sub !== 'string' || payload.sub.length === 0) {
    throw new Error('missing sub');
  }
  if (typeof payload.exp !== 'number' || payload.exp <= now) {
    throw new Error('token expired');
  }

  const jwks = await fetchJwks();
  const jwk = (jwks.keys ?? []).find((k) => k.kid === header.kid);
  if (!jwk) throw new Error('unknown kid');

  const key = await crypto.subtle.importKey(
    'jwk',
    { kty: jwk.kty, n: jwk.n, e: jwk.e, alg: 'RS256', ext: true },
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['verify'],
  );
  const ok = await crypto.subtle.verify(
    'RSASSA-PKCS1-v1_5',
    key,
    b64urlDecodeToBytes(sigPart),
    enc.encode(`${headerPart}.${payloadPart}`),
  );
  if (!ok) throw new Error('bad signature');

  return { uid: payload.sub };
}

function pemToPkcs8Bytes(pem) {
  const body = pem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s+/g, '');
  return b64urlDecodeToBytes(body.replaceAll('+', '-').replaceAll('/', '_'));
}

/// 서비스 계정으로 Google OAuth2 액세스 토큰 발급.
/// serviceAccount: Firebase 콘솔에서 받은 키 JSON (client_email, private_key, token_uri)
export async function getGoogleAccessToken({ serviceAccount, scopes, fetchFn }) {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const claims = {
    iss: serviceAccount.client_email,
    scope: scopes.join(' '),
    aud: serviceAccount.token_uri,
    iat: now,
    exp: now + 3600,
  };
  const signingInput =
    `${b64urlEncodeBytes(enc.encode(JSON.stringify(header)))}.` +
    `${b64urlEncodeBytes(enc.encode(JSON.stringify(claims)))}`;

  const key = await crypto.subtle.importKey(
    'pkcs8',
    pemToPkcs8Bytes(serviceAccount.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const sig = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5', key, enc.encode(signingInput));
  const assertion = `${signingInput}.${b64urlEncodeBytes(new Uint8Array(sig))}`;

  const res = await fetchFn(serviceAccount.token_uri, {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  if (!res.ok) throw new Error(`token exchange failed: ${res.status}`);
  const json = await res.json();
  return { accessToken: json.access_token, expiresIn: json.expires_in ?? 3600 };
}
