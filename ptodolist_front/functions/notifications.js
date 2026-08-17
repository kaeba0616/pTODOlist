// 푸시 메시지 조립 — 트리거(index.js)와 분리된 순수 로직

function buildFriendRequestNotification(request) {
  const name = request && request.fromNickname ? request.fromNickname : null;
  return {
    title: '친구 요청',
    body: name ? `${name}님이 친구 요청을 보냈어요` : '누군가 친구 요청을 보냈어요',
  };
}

function buildFriendAcceptedNotification(accepterNickname) {
  return {
    title: '친구 수락',
    body: accepterNickname
      ? `${accepterNickname}님이 친구 요청을 수락했어요`
      : '친구가 요청을 수락했어요',
  };
}

// friendship.members 중 acceptedBy 가 아닌 쪽 = 원래 요청을 보낸 사람 (푸시 대상)
function otherMemberOf(members, acceptedBy) {
  if (!Array.isArray(members) || members.length !== 2 || !acceptedBy) return null;
  if (!members.includes(acceptedBy)) return null;
  return members[0] === acceptedBy ? members[1] : members[0];
}

module.exports = {
  buildFriendRequestNotification,
  buildFriendAcceptedNotification,
  otherMemberOf,
};
