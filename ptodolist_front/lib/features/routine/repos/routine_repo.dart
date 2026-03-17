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
    if (useMock) return List.unmodifiable(_mockData);
    return _box!.values.toList()..sort((a, b) => a.order.compareTo(b.order));
  }

  List<Routine> getActive() {
    return getAll().where((r) => r.isActive).toList();
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

  String add({required String title, required String categoryId}) {
    final id = _uuid.v4();
    final routine = Routine(
      id: id,
      title: title,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      order: getAll().length,
    );
    if (useMock) {
      _mockData.add(routine);
    } else {
      _box!.put(id, routine);
    }
    return id;
  }

  void update(Routine routine) {
    if (useMock) {
      final index = _mockData.indexWhere((r) => r.id == routine.id);
      if (index != -1) _mockData[index] = routine;
    } else {
      _box!.put(routine.id, routine);
    }
  }

  bool delete(String id) {
    if (useMock) {
      final len = _mockData.length;
      _mockData.removeWhere((r) => r.id == id);
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
      _mockData = _mockData.map((r) {
        if (r.categoryId == oldCategoryId) {
          return r.copyWith(categoryId: newCategoryId);
        }
        return r;
      }).toList();
    } else {
      for (final routine in _box!.values.where((r) => r.categoryId == oldCategoryId)) {
        _box!.put(routine.id, routine.copyWith(categoryId: newCategoryId));
      }
    }
  }
}
