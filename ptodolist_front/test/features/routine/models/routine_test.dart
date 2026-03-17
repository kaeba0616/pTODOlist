import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/routine/models/routine.dart';

void main() {
  group('Routine', () {
    test('생성된다', () {
      final routine = Routine(
        id: '1',
        title: '아침 운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(routine.id, '1');
      expect(routine.title, '아침 운동');
      expect(routine.isActive, true);
      expect(routine.order, 0);
    });

    test('copyWith으로 수정된다', () {
      final original = Routine(
        id: '1', title: '운동', categoryId: 'cat-1', createdAt: DateTime(2026, 1, 1),
      );
      final updated = original.copyWith(title: '헬스', isActive: false);

      expect(updated.title, '헬스');
      expect(updated.isActive, false);
      expect(updated.id, '1');
    });

    test('equality', () {
      final a = Routine(id: '1', title: '운동', categoryId: 'cat-1', createdAt: DateTime(2026, 1, 1));
      final b = Routine(id: '1', title: '운동', categoryId: 'cat-1', createdAt: DateTime(2026, 1, 1));

      expect(a, equals(b));
    });
  });
}
