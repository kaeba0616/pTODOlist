// 푸시 메시지 조립 — 순수 로직

export function buildFriendRequestNotification(fromNickname) {
  return {
    title: '친구 요청',
    body: fromNickname
      ? `${fromNickname}님이 친구 요청을 보냈어요`
      : '누군가 친구 요청을 보냈어요',
  };
}

export function buildFriendAcceptedNotification(accepterNickname) {
  return {
    title: '친구 수락',
    body: accepterNickname
      ? `${accepterNickname}님이 친구 요청을 수락했어요`
      : '친구가 요청을 수락했어요',
  };
}
