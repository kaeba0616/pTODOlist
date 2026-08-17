// pTODOlist 푸시 알림 트리거
// - 친구 요청 생성 → 받은 사람에게 푸시
// - friendship 생성(수락) → 요청을 보냈던 사람에게 푸시
// 배포: firebase deploy --only functions (Blaze 플랜 필요)
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { setGlobalOptions } = require('firebase-functions/v2');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const {
  buildFriendRequestNotification,
  buildFriendAcceptedNotification,
  otherMemberOf,
} = require('./notifications');

initializeApp();
setGlobalOptions({ region: 'asia-northeast3', maxInstances: 5 });

const INVALID_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-argument',
]);

/** uid 의 모든 기기 토큰으로 발송, 무효 토큰은 그 자리에서 정리. */
async function sendToUser(uid, notification) {
  const tokensSnap = await getFirestore()
    .collection('users').doc(uid).collection('fcmTokens').get();
  const tokens = tokensSnap.docs.map((d) => d.id);
  if (tokens.length === 0) {
    console.log(`[push] ${uid}: no tokens, skip`);
    return;
  }
  const result = await getMessaging().sendEachForMulticast({ tokens, notification });
  console.log(`[push] ${uid}: sent=${result.successCount} failed=${result.failureCount}`);
  await Promise.all(result.responses.map((r, i) => {
    if (!r.success && INVALID_TOKEN_CODES.has(r.error?.code)) {
      return tokensSnap.docs[i].ref.delete();
    }
    return null;
  }));
}

// 친구 요청 수신 → 받은 사람에게
exports.onFriendRequestCreated = onDocumentCreated(
  'friendRequests/{toUid}/incoming/{fromUid}',
  async (event) => {
    const data = event.data?.data();
    if (!data) return;
    await sendToUser(event.params.toUid, buildFriendRequestNotification(data));
  },
);

// 요청 수락(friendship 생성) → 요청을 보냈던 사람에게
exports.onFriendshipCreated = onDocumentCreated(
  'friendships/{pairId}',
  async (event) => {
    const data = event.data?.data();
    if (!data) return;
    const target = otherMemberOf(data.members, data.acceptedBy);
    if (!target) {
      console.log(`[push] friendship ${event.params.pairId}: no acceptedBy, skip`);
      return;
    }
    const accepterSnap = await getFirestore()
      .collection('users').doc(data.acceptedBy).get();
    const nickname = accepterSnap.data()?.nickname ?? '';
    await sendToUser(target, buildFriendAcceptedNotification(nickname));
  },
);
