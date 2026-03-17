import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/mocks/category_mock.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class CategoryRepository {
  final bool useMock;
  final Box<Category>? _box;
  List<Category> _mockData = List.from(defaultCategories);

  CategoryRepository({this.useMock = false, Box<Category>? box}) : _box = box;

  static const _uuid = Uuid();

  List<Category> getAll() {
    if (useMock) return List.unmodifiable(_mockData);
    return _box!.values.toList();
  }

  Category? getById(String id) {
    if (useMock) {
      try {
        return _mockData.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    }
    return _box!.get(id);
  }

  String add({required String name, required String color}) {
    final id = _uuid.v4();
    final category = Category(id: id, name: name, color: color);
    if (useMock) {
      _mockData.add(category);
    } else {
      _box!.put(id, category);
    }
    return id;
  }

  void update(Category category) {
    if (useMock) {
      final index = _mockData.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _mockData[index] = category;
      }
    } else {
      _box!.put(category.id, category);
    }
  }

  bool delete(String id) {
    final category = getById(id);
    if (category == null) return false;
    if (category.name == '기타') return false;

    if (useMock) {
      _mockData.removeWhere((c) => c.id == id);
    } else {
      _box!.delete(id);
    }
    return true;
  }
}
