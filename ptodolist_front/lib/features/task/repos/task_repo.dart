import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ptodolist/core/auth/current_user.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';
import 'package:ptodolist/features/task/mocks/task_mock.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class TaskRepository {
  final bool useMock;
  final Box<AdditionalTask>? _box;
  List<AdditionalTask> _mockData = List.from(mockTasks);

  FirebaseFirestore? _firestore;
  String? _uid;

  TaskRepository({
    this.useMock = false,
    Box<AdditionalTask>? box,
    FirebaseFirestore? firestore,
    String? uid,
  })  : _box = box,
        _firestore = firestore,
        _uid = uid;

  void setUid(String? uid) {
    _uid = uid;
  }

  CollectionReference<Map<String, dynamic>> _cloud(String uid) =>
      (_firestore ?? FirebaseFirestore.instance)
          .collection('users')
          .doc(uid)
          .collection('tasks');

  Future<void> _pushCloud(AdditionalTask t) async {
    final uid = _uid ?? CurrentUser.uid;
    if (uid == null) {
      debugPrint('task push skipped: no uid');
      return;
    }
    try {
      await _cloud(uid).doc(t.id).set(t.toMap());
    } catch (e, st) {
      debugPrint('task push FAILED: $e\n$st');
      rethrow;
    }
  }

  Future<void> _deleteCloud(String id) async {
    final uid = _uid ?? CurrentUser.uid;
    if (uid == null) return;
    try {
      await _cloud(uid).doc(id).delete();
    } catch (e, st) {
      debugPrint('task delete FAILED: $e\n$st');
      rethrow;
    }
  }

  static const _uuid = Uuid();
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  List<AdditionalTask> getAll() {
    if (useMock) return List.unmodifiable(_mockData);
    return _box!.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  }

  List<AdditionalTask> getByDate(String date) {
    return getAll().where((t) => t.targetDate == date).toList();
  }

  List<AdditionalTask> getTodayTasks() {
    final today = _dateFmt.format(DateTime.now());
    return getByDate(today);
  }

  List<AdditionalTask> getOverdue(String today) {
    return getAll()
        .where((t) => !t.isCompleted && t.targetDate.compareTo(today) < 0)
        .toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
  }

  List<AdditionalTask> getTodayAndOverdue(String today) {
    final overdue = getOverdue(today);
    final todayTasks = getByDate(today);
    return [...overdue, ...todayTasks];
  }

  List<AdditionalTask> getUpcoming(String today) {
    return getAll()
        .where((t) => t.targetDate.compareTo(today) > 0)
        .toList()
      ..sort((a, b) {
        final d = a.targetDate.compareTo(b.targetDate);
        return d != 0 ? d : a.order.compareTo(b.order);
      });
  }

  AdditionalTask? getById(String id) {
    if (useMock) {
      try {
        return _mockData.firstWhere((t) => t.id == id);
      } catch (_) {
        return null;
      }
    }
    return _box!.get(id);
  }

  Future<void> update(AdditionalTask task) async {
    if (useMock) {
      final index = _mockData.indexWhere((t) => t.id == task.id);
      if (index != -1) _mockData[index] = task;
    } else {
      await _box!.put(task.id, task);
      await _box!.flush();
    }
    await _pushCloud(task);
  }

  Future<String> add({
    required String title,
    required String categoryId,
    String? targetDate,
    List<String> subtasks = const [],
  }) async {
    final id = _uuid.v4();
    final task = AdditionalTask(
      id: id,
      title: title,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      targetDate: targetDate ?? _dateFmt.format(DateTime.now()),
      order: getAll().length,
      subtasks: subtasks,
    );
    if (useMock) {
      _mockData.add(task);
    } else {
      await _box!.put(id, task);
      await _box!.flush();
    }
    await _pushCloud(task);
    return id;
  }

  Future<void> toggleComplete(String id) async {
    final task = getById(id);
    if (task == null) return;
    final newCompleted = !task.isCompleted;
    // 상위 토글 시 모든 서브태스크도 같은 상태로 동기화
    final newSubCompletions = task.subtasks.isEmpty
        ? const <bool>[]
        : List<bool>.filled(task.subtasks.length, newCompleted);
    final updated = task.copyWith(
      isCompleted: newCompleted,
      subtaskCompletions: newSubCompletions,
    );
    if (useMock) {
      final index = _mockData.indexWhere((t) => t.id == id);
      if (index != -1) _mockData[index] = updated;
    } else {
      await _box!.put(id, updated);
      await _box!.flush();
    }
    await _pushCloud(updated);
  }

  Future<void> toggleSubtask(String taskId, int index) async {
    final task = getById(taskId);
    if (task == null) return;
    if (index < 0 || index >= task.subtasks.length) return;

    final completions = List<bool>.from(task.subtaskCompletions);
    while (completions.length < task.subtasks.length) {
      completions.add(false);
    }
    if (completions.length > task.subtasks.length) {
      completions.removeRange(task.subtasks.length, completions.length);
    }
    completions[index] = !completions[index];

    final allDone = completions.every((c) => c);
    final updated = task.copyWith(
      subtaskCompletions: completions,
      isCompleted: allDone,
    );
    if (useMock) {
      final idx = _mockData.indexWhere((t) => t.id == taskId);
      if (idx != -1) _mockData[idx] = updated;
    } else {
      await _box!.put(taskId, updated);
      await _box!.flush();
    }
    await _pushCloud(updated);
  }

  Future<bool> delete(String id) async {
    if (useMock) {
      final len = _mockData.length;
      _mockData.removeWhere((t) => t.id == id);
      await _deleteCloud(id);
      return _mockData.length < len;
    }
    if (_box!.containsKey(id)) {
      await _box!.delete(id);
      await _deleteCloud(id);
      return true;
    }
    return false;
  }

  Future<void> replaceAllLocal(List<AdditionalTask> tasks) async {
    if (useMock) {
      _mockData = List.from(tasks);
      return;
    }
    await _box!.clear();
    for (final t in tasks) {
      await _box!.put(t.id, t);
    }
    await _box!.flush();
  }

  Future<void> reassignCategory(
      String oldCategoryId, String newCategoryId) async {
    if (useMock) {
      final newList = <AdditionalTask>[];
      for (final t in _mockData) {
        if (t.categoryId == oldCategoryId) {
          final updated = t.copyWith(categoryId: newCategoryId);
          await _pushCloud(updated);
          newList.add(updated);
        } else {
          newList.add(t);
        }
      }
      _mockData = newList;
    } else {
      for (final task in _box!.values
          .where((t) => t.categoryId == oldCategoryId)
          .toList()) {
        final updated = task.copyWith(categoryId: newCategoryId);
        await _box!.put(task.id, updated);
        await _pushCloud(updated);
      }
    }
  }
}
