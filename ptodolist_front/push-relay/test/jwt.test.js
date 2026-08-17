// Firebase ID 토큰 검증 로직 테스트
// 실제 Google 서명 대신, 테스트에서 직접 만든 RSA 키로 서명/검증 왕복.
import { describe, it, before } from 'node:test';
import assert from 'node:assert/strict';
import { verifyFirebaseIdToken, b64urlEncodeBytes } from '../src/jwt.js';

const PROJECT = 'ptodolist';
const enc = new TextEncoder();

let keyPair;
let jwk;

function b64urlOfJson(obj) {
  return b64urlEncodeBytes(enc.encode(JSON.stringify(obj)));
}

async function signToken({ header, payload, key = keyPair.privateKey }) {
  const signingInput = `${b64urlOfJson(header)}.${b64urlOfJson(payload)}`;
  const sig = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5', key, enc.encode(signingInput));
  return `${signingInput}.${b64urlEncodeBytes(new Uint8Array(sig))}`;
}

function validPayload(now) {
  return {
    iss: `https://securetoken.google.com/${PROJECT}`,
    aud: PROJECT,
    sub: 'user-123',
    iat: now - 60,
    exp: now + 3600,
  };
}

before(async () => {
  keyPair = await crypto.subtle.generateKey(
    { name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]), hash: 'SHA-256' },
    true, ['sign', 'verify']);
  jwk = { ...(await crypto.subtle.exportKey('jwk', keyPair.publicKey)), kid: 'test-kid' };
});

function opts(now) {
  return {
    projectId: PROJECT,
    fetchJwks: async () => ({ keys: [jwk] }),
    nowSeconds: () => now,
  };
}

describe('verifyFirebaseIdToken', () => {
  const NOW = 1_780_000_000;

  it('올바른 토큰이면 uid(sub) 를 돌려준다', async () => {
    const token = await signToken({
      header: { alg: 'RS256', kid: 'test-kid' },
      payload: validPayload(NOW),
    });
    const { uid } = await verifyFirebaseIdToken(token, opts(NOW));
    assert.equal(uid, 'user-123');
  });

  it('만료된 토큰은 거부한다', async () => {
    const token = await signToken({
      header: { alg: 'RS256', kid: 'test-kid' },
      payload: { ...validPayload(NOW), exp: NOW - 10 },
    });
    await assert.rejects(verifyFirebaseIdToken(token, opts(NOW)));
  });

  it('aud(프로젝트) 가 다르면 거부한다', async () => {
    const token = await signToken({
      header: { alg: 'RS256', kid: 'test-kid' },
      payload: { ...validPayload(NOW), aud: 'other-project' },
    });
    await assert.rejects(verifyFirebaseIdToken(token, opts(NOW)));
  });

  it('iss 가 다르면 거부한다', async () => {
    const token = await signToken({
      header: { alg: 'RS256', kid: 'test-kid' },
      payload: { ...validPayload(NOW), iss: 'https://evil.example.com' },
    });
    await assert.rejects(verifyFirebaseIdToken(token, opts(NOW)));
  });

  it('서명이 다른 키로 됐으면 거부한다', async () => {
    const otherPair = await crypto.subtle.generateKey(
      { name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048,
        publicExponent: new Uint8Array([1, 0, 1]), hash: 'SHA-256' },
      true, ['sign', 'verify']);
    const token = await signToken({
      header: { alg: 'RS256', kid: 'test-kid' },
      payload: validPayload(NOW),
      key: otherPair.privateKey,
    });
    await assert.rejects(verifyFirebaseIdToken(token, opts(NOW)));
  });

  it('alg 가 RS256 이 아니면 거부한다 (none 공격 차단)', async () => {
    const signingInput =
      `${b64urlOfJson({ alg: 'none' })}.${b64urlOfJson(validPayload(NOW))}`;
    await assert.rejects(verifyFirebaseIdToken(`${signingInput}.`, opts(NOW)));
  });

  it('모르는 kid 면 거부한다', async () => {
    const token = await signToken({
      header: { alg: 'RS256', kid: 'unknown-kid' },
      payload: validPayload(NOW),
    });
    await assert.rejects(verifyFirebaseIdToken(token, opts(NOW)));
  });
});
