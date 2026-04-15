import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/routine/mocks/routine_mock.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class RoutineRepository {
  final bool useMock;
  final Box<Routine>? _box;
  List<Routine> _mockData = List.from(mockRoutines);

  RoutineRepository({this.useMock = false, Box<Routine>? box}) : _box = box;

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
  }

  bool delete(String id) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (useMock) {
      final index = _mockData.indexWhere((r) => r.id == id);
      if (index == -1) return false;
      _mockData[index] = _mockData[index].copyWith(deletedAt: () => today);
      return true;
    }
    final routine = _box!.get(id);
    if (routine != null) {
      _box!.put(id, routine.copyWith(deletedAt: () => today));
      return true;
    }
    return false;
  }

  void reassignCategory(String oldCategoryId, String newCategoryId) {
    if (useMock) {
      _mockData = _mockData.map((r) {
        if (r.categoryId == oldCategoryId) {
          return r.copyWith(categoryId: newCategoryId);
        }
        return r;
      }).toList();
    } else {
      for (final routine in _box!.values.where(
        (r) => r.categoryId == oldCategoryId,
      )) {
        _box!.put(routine.id, routine.copyWith(categoryId: newCategoryId));
      }
    }
  }
}
