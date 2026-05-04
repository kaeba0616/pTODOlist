import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptodolist/core/utils/friend_code_generator.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';

class UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _codes =>
      _firestore.collection('friendCodes');

  /// 프로필 읽기. friendCode 가 없으면 자동 발급해서 저장.
  Future<UserProfile?> get(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    var profile = UserProfile.fromMap({...data, 'uid': uid});
    if (profile.friendCode.isEmpty) {
      profile = await _ensureFriendCode(profile);
    }
    return profile;
  }

  Stream<UserProfile?> watch(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return UserProfile.fromMap({...data, 'uid': uid});
    });
  }

  /// 신규/기존 프로필 저장. friendCode 가 비어있으면 자동 생성 후 역방향 인덱스도 같이.
  Future<void> upsert(UserProfile profile) async {
    var p = profile;
    if (p.friendCode.isEmpty) {
      p = await _ensureFriendCode(p);
    }
    await _users.doc(p.uid).set(p.toMap(), SetOptions(merge: true));
  }

  /// friendCode 발급 + /friendCodes/{code} 역방향 인덱스 작성.
  /// 충돌 시 최대 5회 재시도.
  Future<UserProfile> _ensureFriendCode(UserProfile profile) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = FriendCodeGenerator.generate();
      final codeDoc = _codes.doc(code);
      final snap = await codeDoc.get();
      if (snap.exists) continue; // 충돌 → 재시도
      final updated = profile.copyWith(friendCode: code);
      await codeDoc.set({
        'uid': profile.uid,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _users.doc(profile.uid).set(updated.toMap(), SetOptions(merge: true));
      return updated;
    }
    // 5번 다 충돌 — 사실상 일어나지 않지만 안전망
    throw StateError('Could not allocate friendCode after 5 attempts');
  }

  /// 친구 코드 → uid 조회 (요청 보낼 때 사용).
  /// 사용자 입력은 하이픈/공백 유무에 상관없이 받지만, 저장된 doc id 는
  /// generate() 가 만든 display 형식("XXXX-XXXX") 이므로 8자면 하이픈을 끼움.
  Future<String?> findUidByFriendCode(String code) async {
    final normalized = FriendCodeGenerator.normalize(code);
    final docId = normalized.length == 8
        ? '${normalized.substring(0, 4)}-${normalized.substring(4)}'
        : normalized;
    final snap = await _codes.doc(docId).get();
    if (!snap.exists) return null;
    return snap.data()?['uid'] as String?;
  }
}
