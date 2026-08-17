// FCM HTTP v1 발송

const UNREGISTERED_CODES = new Set(['UNREGISTERED', 'INVALID_ARGUMENT']);

export function fcmClient({ projectId, getAccessToken, fetchFn = fetch }) {
  const endpoint =
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

  return {
    /// 단일 토큰 발송 → { ok, unregistered }
    async sendPush({ token, notification }) {
      const accessToken = await getAccessToken();
      const res = await fetchFn(endpoint, {
        method: 'POST',
        headers: {
          authorization: `Bearer ${accessToken}`,
          'content-type': 'application/json',
        },
        body: JSON.stringify({ message: { token, notification } }),
      });
      if (res.ok) return { ok: true, unregistered: false };

      let errorCode = '';
      try {
        const err = await res.json();
        errorCode = err.error?.details
          ?.find((d) => d['@type']?.includes('FcmError'))?.errorCode
          ?? err.error?.status ?? '';
      } catch { /* 본문 없음 */ }
      const unregistered =
        res.status === 404 || UNREGISTERED_CODES.has(errorCode);
      console.log(`[push] send failed: ${res.status} ${errorCode}`);
      return { ok: false, unregistered };
    },
  };
}
