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
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = original.copyWith(title: '헬스', isActive: false);

      expect(updated.title, '헬스');
      expect(updated.isActive, false);
      expect(updated.id, '1');
    });

    test('equality', () {
      final a = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
      );
      final b = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(a, equals(b));
    });

    test('subtasks 기본값은 빈 리스트이다', () {
      final routine = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(routine.subtasks, isEmpty);
    });

    test('subtasks와 함께 생성된다', () {
      final routine = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
        subtasks: ['스트레칭', '러닝'],
      );
      expect(routine.subtasks, ['스트레칭', '러닝']);
    });

    test('copyWith으로 subtasks를 수정한다', () {
      final original = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
        subtasks: ['스트레칭'],
      );
      final updated = original.copyWith(subtasks: ['스트레칭', '러닝']);
      expect(updated.subtasks, ['스트레칭', '러닝']);
      expect(original.subtasks, ['스트레칭']); // 원본 불변
    });

    test('subtasks가 다르면 동등하지 않다', () {
      final a = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
        subtasks: ['스트레칭'],
      );
      final b = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
        subtasks: ['러닝'],
      );
      expect(a, isNot(equals(b)));
    });

    test('subtasks가 같으면 동등하다', () {
      final a = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
        subtasks: ['스트레칭', '러닝'],
      );
      final b = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
        subtasks: ['스트레칭', '러닝'],
      );
      expect(a, equals(b));
    });

    test('priority 기본값은 1(보통)이다', () {
      final routine = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(routine.priority, 1);
    });

    test('priority를 지정하여 생성한다', () {
      final routine = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
        priority: 2,
      );
      expect(routine.priority, 2);
    });

    test('copyWith으로 priority를 변경한다', () {
      final original = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = original.copyWith(priority: 0);
      expect(updated.priority, 0);
      expect(original.priority, 1);
    });

    test('priority가 다르면 동등하지 않다', () {
      final a = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
        priority: 2,
      );
      final b = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
        priority: 0,
      );
      expect(a, isNot(equals(b)));
    });

    test('iconCodePoint 기본값은 null이다', () {
      final routine = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(routine.iconCodePoint, isNull);
    });

    test('iconCodePoint를 지정하여 생성한다', () {
      final routine = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
        iconCodePoint: 0xe613, // fitness_center
      );
      expect(routine.iconCodePoint, 0xe613);
    });

    test('copyWith으로 iconCodePoint를 변경한다', () {
      final original = Routine(
        id: '1',
        title: '운동',
        categoryId: 'cat-1',
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = original.copyWith(iconCodePoint: () => 0xe613);
      expect(updated.iconCodePoint, 0xe613);
      expect(original.iconCodePoint, isNull);
    });
  });
}
