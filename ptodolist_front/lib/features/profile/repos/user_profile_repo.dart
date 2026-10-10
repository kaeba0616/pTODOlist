import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';

/// Firestore `/users/{uid}` 프로필 CRUD (본인 전용).
class UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<UserProfile?> get(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return UserProfile.fromMap({...data, 'uid': uid});
  }

  Stream<UserProfile?> watch(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return UserProfile.fromMap({...data, 'uid': uid});
    });
  }

  /// 신규/기존 프로필 저장 (merge).
  Future<void> upsert(UserProfile profile) async {
    await _users.doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
  }
}
