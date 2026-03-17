import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/mocks/category_mock.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class CategoryRepository {
  final bool useMock;
  final Box? _box;
  List<Category> _mockData = List.from(defaultCategories);

  CategoryRepository({this.useMock = false, Box? box}) : _box = box;

  static const _uuid = Uuid();

  List<Category> getAll() {
    if (useMock) return List.unmodifiable(_mockData);
    // Real implementation will be in Step 4
    return [];
  }

  Category? getById(String id) {
    if (useMock) {
      try {
        return _mockData.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String add({required String name, required String color}) {
    final id = _uuid.v4();
    final category = Category(id: id, name: name, color: color);
    if (useMock) {
      _mockData.add(category);
    }
    return id;
  }

  void update(Category category) {
    if (useMock) {
      final index = _mockData.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _mockData[index] = category;
      }
    }
  }

  bool delete(String id) {
    // "기타" 카테고리는 삭제 불가
    if (useMock) {
      final category = getById(id);
      if (category == null) return false;
      if (category.name == '기타') return false;
      _mockData.removeWhere((c) => c.id == id);
      return true;
    }
    return false;
  }
}
