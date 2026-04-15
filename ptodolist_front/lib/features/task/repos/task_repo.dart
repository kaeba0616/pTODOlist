import 'package:ptodolist/features/task/models/additional_task.dart';
import 'package:ptodolist/features/task/mocks/task_mock.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class TaskRepository {
  final bool useMock;
  final Box<AdditionalTask>? _box;
  List<AdditionalTask> _mockData = List.from(mockTasks);

  TaskRepository({this.useMock = false, Box<AdditionalTask>? box}) : _box = box;

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
    return id;
  }

  Future<void> toggleComplete(String id) async {
    final task = getById(id);
    if (task == null) return;
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    if (useMock) {
      final index = _mockData.indexWhere((t) => t.id == id);
      if (index != -1) _mockData[index] = updated;
    } else {
      await _box!.put(id, updated);
      await _box!.flush();
    }
  }

  bool delete(String id) {
    if (useMock) {
      final len = _mockData.length;
      _mockData.removeWhere((t) => t.id == id);
      return _mockData.length < len;
    }
    if (_box!.containsKey(id)) {
      _box!.delete(id);
      return true;
    }
    return false;
  }

  void reassignCategory(String oldCategoryId, String newCategoryId) {
    if (useMock) {
      _mockData = _mockData.map((t) {
        if (t.categoryId == oldCategoryId) {
          return t.copyWith(categoryId: newCategoryId);
        }
        return t;
      }).toList();
    } else {
      for (final task in _box!.values.where(
        (t) => t.categoryId == oldCategoryId,
      )) {
        _box!.put(task.id, task.copyWith(categoryId: newCategoryId));
      }
    }
  }
}
