import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/models/category_adapter.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';
import 'dart:io';

void main() {
  late Box<Category> box;
  late CategoryRepository repo;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    box = await Hive.openBox<Category>('test_categories');
    repo = CategoryRepository(box: box);
  });

  tearDown(() async {
    await box.clear();
    await box.close();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('CategoryRepository (Hive)', () {
    test('빈 박스에서 빈 리스트를 반환한다', () async {
      expect(repo.getAll(), isEmpty);
    });

    test('카테고리를 추가하고 조회한다', () async {
      final id = await repo.add(name: '운동', color: '#EF4444');

      final all = repo.getAll();
      expect(all.length, 1);
      expect(all.first.name, '운동');

      final found = repo.getById(id);
      expect(found, isNotNull);
      expect(found!.color, '#EF4444');
    });

    test('카테고리를 수정한다', () async {
      final id = await repo.add(name: '운동', color: '#EF4444');
      final original = repo.getById(id)!;
      await repo.update(original.copyWith(name: '헬스'));

      expect(repo.getById(id)!.name, '헬스');
    });

    test('카테고리를 삭제한다', () async {
      final id = await repo.add(name: '운동', color: '#EF4444');
      final result = await repo.delete(id);

      expect(result, true);
      expect(repo.getAll(), isEmpty);
    });

    test('"기타" 카테고리는 삭제할 수 없다', () async {
      final id = await repo.add(name: '기타', color: '#8B5CF6');
      final result = await repo.delete(id);

      expect(result, false);
      expect(repo.getAll().length, 1);
    });

    test('데이터가 박스에 영속된다', () async {
      await repo.add(name: '공부', color: '#3B82F6');

      // 박스를 닫고 다시 열기
      await box.close();
      box = await Hive.openBox<Category>('test_categories');
      final newRepo = CategoryRepository(box: box);

      expect(newRepo.getAll().length, 1);
      expect(newRepo.getAll().first.name, '공부');
    });
  });
}
