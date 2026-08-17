// 푸시 메시지 조립 로직 (functions/ 에서 이관한 스펙과 동일)
import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import {
  buildFriendRequestNotification,
  buildFriendAcceptedNotification,
} from '../src/notifications.js';

describe('buildFriendRequestNotification', () => {
  it('보낸 사람 닉네임을 본문에 넣는다', () => {
    const n = buildFriendRequestNotification('민섭');
    assert.equal(n.title, '친구 요청');
    assert.equal(n.body, '민섭님이 친구 요청을 보냈어요');
  });

  it('닉네임이 없으면 대체 문구를 쓴다', () => {
    assert.equal(buildFriendRequestNotification('').body, '누군가 친구 요청을 보냈어요');
    assert.equal(buildFriendRequestNotification(null).body, '누군가 친구 요청을 보냈어요');
  });
});

describe('buildFriendAcceptedNotification', () => {
  it('수락한 사람 닉네임을 본문에 넣는다', () => {
    const n = buildFriendAcceptedNotification('민섭');
    assert.equal(n.title, '친구 수락');
    assert.equal(n.body, '민섭님이 친구 요청을 수락했어요');
  });

  it('닉네임이 비어있으면 대체 문구를 쓴다', () => {
    assert.equal(buildFriendAcceptedNotification('').body, '친구가 요청을 수락했어요');
  });
});
