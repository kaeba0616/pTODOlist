import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:ptodolist/core/auth/current_user.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/mocks/category_mock.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class CategoryRepository {
  final bool useMock;
  final Box<Category>? _box;
  List<Category> _mockData = List.from(defaultCategories);

  FirebaseFirestore? _firestore;
  String? _uid;

  CategoryRepository({
    this.useMock = false,
    Box<Category>? box,
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
          .collection('categories');

  Future<void> _pushCloud(Category c) async {
    final uid = _uid ?? CurrentUser.uid;
    if (uid == null) return;
    try {
      await _cloud(uid).doc(c.id).set(c.toMap());
    } catch (e, st) {
      debugPrint('category push FAILED: $e\n$st');
      rethrow;
    }
  }

  Future<void> _deleteCloud(String id) async {
    final uid = _uid ?? CurrentUser.uid;
    if (uid == null) return;
    try {
      await _cloud(uid).doc(id).delete();
    } catch (e, st) {
      debugPrint('category delete FAILED: $e\n$st');
      rethrow;
    }
  }

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

  Future<String> add({required String name, required String color}) async {
    final id = _uuid.v4();
    final category = Category(id: id, name: name, color: color);
    if (useMock) {
      _mockData.add(category);
    } else {
      await _box!.put(id, category);
    }
    await _pushCloud(category);
    return id;
  }

  Future<void> update(Category category) async {
    if (useMock) {
      final index = _mockData.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _mockData[index] = category;
      }
    } else {
      await _box!.put(category.id, category);
    }
    await _pushCloud(category);
  }

  Future<bool> delete(String id) async {
    final category = getById(id);
    if (category == null) return false;
    if (category.name == '기타') return false;

    if (useMock) {
      _mockData.removeWhere((c) => c.id == id);
    } else {
      await _box!.delete(id);
    }
    await _deleteCloud(id);
    return true;
  }

  Future<void> replaceAllLocal(List<Category> categories) async {
    if (useMock) {
      _mockData = List.from(categories);
      return;
    }
    await _box!.clear();
    for (final c in categories) {
      await _box!.put(c.id, c);
    }
  }
}
