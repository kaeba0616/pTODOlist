import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptodolist/features/friends/models/friendship.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';

/// 친구 요청/수락/거절/삭제 + 친구 목록 조회.
class FriendsRepository {
  final FirebaseFirestore _firestore;

  FriendsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _friendships =>
      _firestore.collection('friendships');

  CollectionReference<Map<String, dynamic>> _incoming(String toUid) =>
      _firestore.collection('friendRequests').doc(toUid).collection('incoming');

  /// 내가 보낸 친구 요청. 중복 요청은 덮어쓰기 (set merge).
  Future<void> sendRequest({
    required String toUid,
    required UserProfile fromProfile,
  }) async {
    if (toUid == fromProfile.uid) {
      throw ArgumentError('cannot send request to self');
    }
    // 이미 친구면 요청 안 보냄
    final pairId = Friendship.makePairId(fromProfile.uid, toUid);
    final existing = await _friendships.doc(pairId).get();
    if (existing.exists) {
      throw StateError('already-friends');
    }
    final req = {
      'fromUid': fromProfile.uid,
      'fromNickname': fromProfile.nickname,
      'fromCode': fromProfile.friendCode,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _incoming(toUid).doc(fromProfile.uid).set(req);
  }

  /// 받은 요청 목록 (실시간).
  Stream<List<FriendRequest>> watchIncoming(String myUid) {
    return _incoming(myUid).snapshots().map(
          (snap) =>
              snap.docs.map((d) => FriendRequest.fromMap(d.data())).toList(),
        );
  }

  /// 요청 수락 — friendship 생성 + 받은 요청 삭제.
  Future<void> accept({
    required String myUid,
    required String fromUid,
  }) async {
    final pairId = Friendship.makePairId(myUid, fromUid);
    final members = [myUid, fromUid]..sort();
    await _friendships.doc(pairId).set({
      'members': members,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _incoming(myUid).doc(fromUid).delete();
  }

  /// 요청 거절 — 받은 요청만 삭제.
  Future<void> decline({
    required String myUid,
    required String fromUid,
  }) async {
    await _incoming(myUid).doc(fromUid).delete();
  }

  /// 친구 끊기.
  Future<void> removeFriend({
    required String myUid,
    required String otherUid,
  }) async {
    final pairId = Friendship.makePairId(myUid, otherUid);
    await _friendships.doc(pairId).delete();
  }

  /// 내 친구 목록 (실시간).
  Stream<List<Friendship>> watchMyFriendships(String myUid) {
    return _friendships
        .where('members', arrayContains: myUid)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Friendship.fromMap(d.id, d.data()))
            .toList());
  }
}
