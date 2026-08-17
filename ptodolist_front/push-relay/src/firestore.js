// Firestore REST API 클라이언트 (Admin 권한 access token 사용)

function decodeFields(fields) {
  const out = {};
  for (const [k, v] of Object.entries(fields ?? {})) {
    if ('stringValue' in v) out[k] = v.stringValue;
    else if ('integerValue' in v) out[k] = Number(v.integerValue);
    else if ('doubleValue' in v) out[k] = v.doubleValue;
    else if ('booleanValue' in v) out[k] = v.booleanValue;
    else if ('arrayValue' in v) {
      out[k] = (v.arrayValue.values ?? []).map((e) => e.stringValue ?? e);
    }
  }
  return out;
}

export function firestoreClient({ projectId, getAccessToken, fetchFn = fetch }) {
  const base =
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;

  async function call(method, path, query = '') {
    const token = await getAccessToken();
    return fetchFn(`${base}/${path}${query}`, {
      method,
      headers: { authorization: `Bearer ${token}` },
    });
  }

  return {
    /// 문서 조회 — 존재하면 필드(plain object), 없으면 null
    async getDoc(path) {
      const res = await call('GET', path);
      if (res.status === 404) return null;
      if (!res.ok) throw new Error(`firestore get ${path}: ${res.status}`);
      return decodeFields((await res.json()).fields);
    },

    /// 컬렉션의 문서 ID 목록 (fcmTokens 는 문서ID=토큰)
    async listCollection(path) {
      const res = await call('GET', path, '?pageSize=300&mask.fieldPaths=__name__');
      if (res.status === 404) return [];
      if (!res.ok) throw new Error(`firestore list ${path}: ${res.status}`);
      const json = await res.json();
      return (json.documents ?? []).map((d) => d.name.split('/').pop());
    },

    async deleteDoc(path) {
      const res = await call('DELETE', path);
      if (!res.ok && res.status !== 404) {
        throw new Error(`firestore delete ${path}: ${res.status}`);
      }
    },
  };
}
