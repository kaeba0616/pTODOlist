import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ptodolist/features/social/models/daily_share.dart';

class DailyShareRepository {
  final FirebaseFirestore _firestore;

  DailyShareRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _shares =>
      _firestore.collection('dailyShares');

  Future<void> upsert(DailyShare share) async {
    await _shares.doc(DailyShare.docId(share.uid, share.date)).set(
          share.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> delete(String uid, String date) async {
    await _shares.doc(DailyShare.docId(uid, date)).delete();
  }

  /// 특정 날짜의 모든 사람 피드 (자기 포함). updatedAt 내림차순.
  Stream<List<DailyShare>> watchByDate(String date, {int limit = 100}) {
    return _shares
        .where('date', isEqualTo: date)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DailyShare.fromMap(d.data()))
            .toList());
  }

  /// 특정 사용자의 특정 날짜 share (실시간).
  Stream<DailyShare?> watchUserDate(String uid, String date) {
    return _shares.doc(DailyShare.docId(uid, date)).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return DailyShare.fromMap(data);
    });
  }
}
