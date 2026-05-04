import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ptodolist/core/auth/current_user.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/routine/mocks/routine_mock.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class RoutineRepository {
  final bool useMock;
  final Box<Routine>? _box;
  List<Routine> _mockData = List.from(mockRoutines);

  /// Cloud sync (선택적) — uid 가 set 된 경우에만 Firestore mirror 작동.
  FirebaseFirestore? _firestore;
  String? _uid;

  RoutineRepository({
    this.useMock = false,
    Box<Routine>? box,
    FirebaseFirestore? firestore,
    String? uid,
  })  : _box = box,
        _firestore = firestore,
        _uid = uid;

  /// 로그인 시 호출. null = 로그아웃.
  void setUid(String? uid) {
    _uid = uid;
  }

  CollectionReference<Map<String, dynamic>> _cloud(String uid) =>
      (_firestore ?? FirebaseFirestore.instance)
          .collection('users')
          .doc(uid)
          .collection('routines');

  void _pushCloud(Routine r) {
    final uid = _uid ?? CurrentUser.uid;
    if (uid == null) return;
    _cloud(uid).doc(r.id).set(r.toMap()).catchError((Object e, StackTrace st) {
      debugPrint('routine push failed: $e');
    });
  }

  void _deleteCloud(String id) {
    final uid = _uid ?? CurrentUser.uid;
    if (uid == null) return;
    _cloud(uid).doc(id).delete().catchError((Object e, StackTrace st) {
      debugPrint('routine delete failed: $e');
    });
  }

  static const _uuid = Uuid();

  List<Routine> getAll() {
    if (useMock) return List.unmodifiable(_mockData.where((r) => !r.isDeleted));
    return _box!.values.where((r) => !r.isDeleted).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<Routine> getActive() {
    return getAll().where((r) => r.isActive && !r.isDeleted).toList();
  }

  List<Routine> getActiveForDay(int weekday) {
    return getActive().where((r) => r.isActiveOnDay(weekday)).toList();
  }

  /// 삭제된 루틴 포함 전체 목록 (캘린더/통계용)
  List<Routine> getAllIncludingDeleted() {
    if (useMock) return List.unmodifiable(_mockData);
    return _box!.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  }

  Routine? getById(String id) {
    if (useMock) {
      try {
        return _mockData.firstWhere((r) => r.id == id);
      } catch (_) {
        return null;
      }
    }
    return _box!.get(id);
  }

  Future<String> add({
    required String title,
    required String categoryId,
    List<String> subtasks = const [],
    int priority = 1,
    int? iconCodePoint,
    List<int> activeDays = const [],
  }) async {
    final id = _uuid.v4();
    final routine = Routine(
      id: id,
      title: title,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      order: getAll().length,
      subtasks: subtasks,
      priority: priority,
      iconCodePoint: iconCodePoint,
      activeDays: activeDays,
    );
    if (useMock) {
      _mockData.add(routine);
    } else {
      await _box!.put(id, routine);
      await _box!.flush();
    }
    _pushCloud(routine);
    return id;
  }

  Future<void> update(Routine routine) async {
    if (useMock) {
      final index = _mockData.indexWhere((r) => r.id == routine.id);
      if (index != -1) _mockData[index] = routine;
    } else {
      await _box!.put(routine.id, routine);
      await _box!.flush();
    }
    _pushCloud(routine);
  }

  bool delete(String id) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (useMock) {
      final index = _mockData.indexWhere((r) => r.id == id);
      if (index == -1) return false;
      final updated = _mockData[index].copyWith(deletedAt: () => today);
      _mockData[index] = updated;
      _pushCloud(updated);
      return true;
    }
    final routine = _box!.get(id);
    if (routine != null) {
      final updated = routine.copyWith(deletedAt: () => today);
      _box!.put(id, updated);
      _pushCloud(updated);
      return true;
    }
    return false;
  }

  void reassignCategory(String oldCategoryId, String newCategoryId) {
    if (useMock) {
      _mockData = _mockData.map((r) {
        if (r.categoryId == oldCategoryId) {
          final updated = r.copyWith(categoryId: newCategoryId);
          _pushCloud(updated);
          return updated;
        }
        return r;
      }).toList();
    } else {
      for (final routine in _box!.values.where(
        (r) => r.categoryId == oldCategoryId,
      )) {
        final updated = routine.copyWith(categoryId: newCategoryId);
        _box!.put(routine.id, updated);
        _pushCloud(updated);
      }
    }
  }

  /// CloudSyncService 가 pull 한 후 일괄 적용할 때 사용.
  /// 로컬을 비우고 새 데이터로 채움. cloud push 안 함 (pull 결과니까).
  Future<void> replaceAllLocal(List<Routine> routines) async {
    if (useMock) {
      _mockData = List.from(routines);
      return;
    }
    await _box!.clear();
    for (final r in routines) {
      await _box!.put(r.id, r);
    }
    await _box!.flush();
  }
}
