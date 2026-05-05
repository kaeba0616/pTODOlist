import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';

void main() {
  group('CategoryRepository (Mock)', () {
    late CategoryRepository repo;

    setUp(() {
      repo = CategoryRepository(useMock: true);
    });

    test('기본 카테고리 5개가 반환된다', () async {
      final categories = repo.getAll();

      expect(categories.length, 5);
      expect(categories[0].name, '운동');
      expect(categories[4].name, '기타');
    });

    test('ID로 카테고리를 조회한다', () async {
      final category = repo.getById('cat-1');

      expect(category, isNotNull);
      expect(category!.name, '운동');
    });

    test('존재하지 않는 ID는 null을 반환한다', () async {
      final category = repo.getById('nonexistent');

      expect(category, isNull);
    });

    test('새 카테고리를 추가한다', () async {
      final id = await repo.add(name: '취미', color: '#EC4899');
      final categories = repo.getAll();

      expect(categories.length, 6);
      expect(id, isNotEmpty);

      final added = repo.getById(id);
      expect(added, isNotNull);
      expect(added!.name, '취미');
    });

    test('카테고리를 수정한다', () async {
      final original = repo.getById('cat-1')!;
      final updated = original.copyWith(name: '헬스');
      await repo.update(updated);

      final result = repo.getById('cat-1');
      expect(result!.name, '헬스');
    });

    test('카테고리를 삭제한다', () async {
      final result = await repo.delete('cat-1');

      expect(result, true);
      expect(repo.getAll().length, 4);
      expect(repo.getById('cat-1'), isNull);
    });

    test('"기타" 카테고리는 삭제할 수 없다', () async {
      final result = await repo.delete('cat-5');

      expect(result, false);
      expect(repo.getAll().length, 5);
    });
  });
}
