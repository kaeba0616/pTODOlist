import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/category/models/category.dart';

void main() {
  group('Category', () {
    test('생성된다', () {
      const category = Category(
        id: '1',
        name: '운동',
        color: '#EF4444',
      );

      expect(category.id, '1');
      expect(category.name, '운동');
      expect(category.color, '#EF4444');
      expect(category.icon, isNull);
    });

    test('copyWith으로 복사 및 수정된다', () {
      const original = Category(id: '1', name: '운동', color: '#EF4444');
      final copied = original.copyWith(name: '공부', color: '#3B82F6');

      expect(copied.id, '1');
      expect(copied.name, '공부');
      expect(copied.color, '#3B82F6');
    });

    test('같은 값이면 동일하다 (equality)', () {
      const a = Category(id: '1', name: '운동', color: '#EF4444');
      const b = Category(id: '1', name: '운동', color: '#EF4444');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('다른 값이면 다르다', () {
      const a = Category(id: '1', name: '운동', color: '#EF4444');
      const b = Category(id: '2', name: '공부', color: '#3B82F6');

      expect(a, isNot(equals(b)));
    });
  });
}
