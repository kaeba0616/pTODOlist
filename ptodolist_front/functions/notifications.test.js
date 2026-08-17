// 푸시 메시지 조립 로직 테스트 (트리거와 분리된 순수 함수)
// 실행: cd functions && npm test
const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const {
  buildFriendRequestNotification,
  buildFriendAcceptedNotification,
  otherMemberOf,
} = require('./notifications');

describe('buildFriendRequestNotification', () => {
  it('보낸 사람 닉네임을 본문에 넣는다', () => {
    const n = buildFriendRequestNotification({ fromNickname: '민섭' });
    assert.equal(n.title, '친구 요청');
    assert.equal(n.body, '민섭님이 친구 요청을 보냈어요');
  });

  it('닉네임이 없으면 대체 문구를 쓴다', () => {
    const n = buildFriendRequestNotification({});
    assert.equal(n.body, '누군가 친구 요청을 보냈어요');
  });
});

describe('buildFriendAcceptedNotification', () => {
  it('수락한 사람 닉네임을 본문에 넣는다', () => {
    const n = buildFriendAcceptedNotification('민섭');
    assert.equal(n.title, '친구 수락');
    assert.equal(n.body, '민섭님이 친구 요청을 수락했어요');
  });

  it('닉네임이 비어있으면 대체 문구를 쓴다', () => {
    const n = buildFriendAcceptedNotification('');
    assert.equal(n.body, '친구가 요청을 수락했어요');
  });
});

describe('otherMemberOf', () => {
  it('acceptedBy 가 아닌 나머지 멤버(=요청 보낸 사람)를 돌려준다', () => {
    assert.equal(otherMemberOf(['alice', 'bob'], 'bob'), 'alice');
    assert.equal(otherMemberOf(['alice', 'bob'], 'alice'), 'bob');
  });

  it('비정상 데이터면 null (멤버 아님 / 필드 없음 / 배열 아님)', () => {
    assert.equal(otherMemberOf(['alice', 'bob'], 'carol'), null);
    assert.equal(otherMemberOf(['alice', 'bob'], undefined), null);
    assert.equal(otherMemberOf('alice_bob', 'alice'), null);
    assert.equal(otherMemberOf(['alice'], 'alice'), null);
  });
});
