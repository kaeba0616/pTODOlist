import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';

/// 로그인/계정전환 시 Firestore → 로컬 Hive 채움.
/// 로그아웃 시 로컬 비움.
/// repos 의 setUid() 도 같이 관리해서 push-through 가 정확한 user 로 가도록.
class CloudSyncService {
  final FirebaseFirestore _firestore;
  final RoutineRepository routineRepo;
  final CategoryRepository categoryRepo;
  final TaskRepository taskRepo;
  final DailyRecordRepository dailyRecordRepo;

  CloudSyncService({
    FirebaseFirestore? firestore,
    required this.routineRepo,
    required this.categoryRepo,
    required this.taskRepo,
    required this.dailyRecordRepo,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userColl(String uid, String name) =>
      _firestore.collection('users').doc(uid).collection(name);

  /// 로그인 직후 Firestore 의 본인 데이터 전부를 로컬에 덮어씀.
  /// 빈 결과면 로컬도 빈 상태가 됨 (= 신규 가입자).
  Future<void> pullAll(String uid) async {
    try {
      // 4 컬렉션 병렬 조회
      final results = await Future.wait([
        _userColl(uid, 'routines').get(),
        _userColl(uid, 'categories').get(),
        _userColl(uid, 'tasks').get(),
        _userColl(uid, 'dailyRecords').get(),
      ]);

      final routines = results[0]
          .docs
          .map((d) => Routine.fromMap({...d.data(), 'id': d.id}))
          .toList();
      final categories = results[1]
          .docs
          .map((d) => Category.fromMap({...d.data(), 'id': d.id}))
          .toList();
      final tasks = results[2]
          .docs
          .map((d) => AdditionalTask.fromMap({...d.data(), 'id': d.id}))
          .toList();
      final records = results[3]
          .docs
          .map((d) => DailyRecord.fromMap({...d.data(), 'date': d.id}))
          .toList();

      await routineRepo.replaceAllLocal(routines);
      await categoryRepo.replaceAllLocal(categories);
      await taskRepo.replaceAllLocal(tasks);
      await dailyRecordRepo.replaceAllLocal(records);
      debugPrint('CloudSync.pullAll($uid): r=${routines.length}, '
          'c=${categories.length}, t=${tasks.length}, dr=${records.length}');
    } catch (e, st) {
      debugPrint('CloudSync.pullAll failed: $e\n$st');
      rethrow;
    }
  }

  /// 로그아웃: 로컬 Hive 전체 비움 + repo uid 제거.
  Future<void> wipeLocal() async {
    routineRepo.setUid(null);
    categoryRepo.setUid(null);
    taskRepo.setUid(null);
    dailyRecordRepo.setUid(null);
    await routineRepo.replaceAllLocal(const []);
    await categoryRepo.replaceAllLocal(const []);
    await taskRepo.replaceAllLocal(const []);
    await dailyRecordRepo.replaceAllLocal(const []);
  }

  /// 모든 repo 에 새 uid 주입 (로그인 후 push-through 작동시키려면 필요).
  void bindUid(String uid) {
    routineRepo.setUid(uid);
    categoryRepo.setUid(uid);
    taskRepo.setUid(uid);
    dailyRecordRepo.setUid(uid);
  }

  /// 첫 로그인 시 기존 로컬 데이터를 클라우드로 올림.
  /// (마이그레이션용 — 이미 cloud 에 데이터 있으면 호출하지 않는 게 좋음)
  /// 결과로 각 컬렉션 push 개수 + 에러 반환 (디버깅 용).
  Future<ForcePushResult> forcePushAll(String uid) async {
    try {
      bindUid(uid);
      final batch = _firestore.batch();
      int r = 0, c = 0, t = 0, d = 0;
      for (final routine in routineRepo.getAllIncludingDeleted()) {
        batch.set(_userColl(uid, 'routines').doc(routine.id), routine.toMap());
        r++;
      }
      for (final cat in categoryRepo.getAll()) {
        batch.set(_userColl(uid, 'categories').doc(cat.id), cat.toMap());
        c++;
      }
      for (final task in taskRepo.getAll()) {
        batch.set(_userColl(uid, 'tasks').doc(task.id), task.toMap());
        t++;
      }
      final dailyKeys = dailyRecordRepo.getRecordsInRange(
          '0000-01-01', '9999-12-31');
      for (final dr in dailyKeys) {
        batch.set(_userColl(uid, 'dailyRecords').doc(dr.date), dr.toMap());
        d++;
      }
      await batch.commit();
      return ForcePushResult(
          routines: r, categories: c, tasks: t, dailyRecords: d);
    } catch (e, st) {
      debugPrint('forcePushAll failed: $e\n$st');
      return ForcePushResult(error: e, stackTrace: st);
    }
  }

  /// 하위호환 (기존 호출자) — 결과는 무시.
  Future<void> pushAllExisting(String uid) => forcePushAll(uid);
}

class ForcePushResult {
  final int routines;
  final int categories;
  final int tasks;
  final int dailyRecords;
  final Object? error;
  final StackTrace? stackTrace;

  const ForcePushResult({
    this.routines = 0,
    this.categories = 0,
    this.tasks = 0,
    this.dailyRecords = 0,
    this.error,
    this.stackTrace,
  });

  bool get isError => error != null;
  int get total => routines + categories + tasks + dailyRecords;
}
