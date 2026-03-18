import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';

void main() {
  group('AdditionalTask', () {
    test('생성된다', () {
      final task = AdditionalTask(
        id: '1',
        title: '마트 장보기',
        categoryId: 'cat-4',
        createdAt: DateTime(2026, 3, 17),
        targetDate: '2026-03-17',
      );

      expect(task.id, '1');
      expect(task.title, '마트 장보기');
      expect(task.isCompleted, false);
      expect(task.targetDate, '2026-03-17');
    });

    test('copyWith으로 완료 토글한다', () {
      final task = AdditionalTask(
        id: '1',
        title: '마트',
        categoryId: 'cat-4',
        createdAt: DateTime(2026, 3, 17),
        targetDate: '2026-03-17',
      );
      final completed = task.copyWith(isCompleted: true);

      expect(completed.isCompleted, true);
      expect(completed.id, '1');
    });

    test('equality', () {
      final a = AdditionalTask(
        id: '1',
        title: '마트',
        categoryId: 'cat-4',
        createdAt: DateTime(2026, 3, 17),
        targetDate: '2026-03-17',
      );
      final b = AdditionalTask(
        id: '1',
        title: '마트',
        categoryId: 'cat-4',
        createdAt: DateTime(2026, 3, 17),
        targetDate: '2026-03-17',
      );

      expect(a, equals(b));
    });

    test('subtasks 기본값은 빈 리스트이다', () {
      final task = AdditionalTask(
        id: '1',
        title: '마트',
        categoryId: 'cat-4',
        createdAt: DateTime(2026, 3, 17),
        targetDate: '2026-03-17',
      );
      expect(task.subtasks, isEmpty);
    });

    test('subtasks와 함께 생성된다', () {
      final task = AdditionalTask(
        id: '1',
        title: '마트',
        categoryId: 'cat-4',
        createdAt: DateTime(2026, 3, 17),
        targetDate: '2026-03-17',
        subtasks: ['우유', '계란'],
      );
      expect(task.subtasks, ['우유', '계란']);
    });

    test('copyWith으로 subtasks를 수정한다', () {
      final original = AdditionalTask(
        id: '1',
        title: '마트',
        categoryId: 'cat-4',
        createdAt: DateTime(2026, 3, 17),
        targetDate: '2026-03-17',
        subtasks: ['우유'],
      );
      final updated = original.copyWith(subtasks: ['우유', '계란']);
      expect(updated.subtasks, ['우유', '계란']);
      expect(original.subtasks, ['우유']);
    });

    test('subtasks가 다르면 동등하지 않다', () {
      final a = AdditionalTask(
        id: '1',
        title: '마트',
        categoryId: 'cat-4',
        createdAt: DateTime(2026, 3, 17),
        targetDate: '2026-03-17',
        subtasks: ['우유'],
      );
      final b = AdditionalTask(
        id: '1',
        title: '마트',
        categoryId: 'cat-4',
        createdAt: DateTime(2026, 3, 17),
        targetDate: '2026-03-17',
        subtasks: ['계란'],
      );
      expect(a, isNot(equals(b)));
    });

    test('subtasks가 같으면 동등하다', () {
      final a = AdditionalTask(
        id: '1',
        title: '마트',
        categoryId: 'cat-4',
        createdAt: DateTime(2026, 3, 17),
        targetDate: '2026-03-17',
        subtasks: ['우유', '계란'],
      );
      final b = AdditionalTask(
        id: '1',
        title: '마트',
        categoryId: 'cat-4',
        createdAt: DateTime(2026, 3, 17),
        targetDate: '2026-03-17',
        subtasks: ['우유', '계란'],
      );
      expect(a, equals(b));
    });
  });
}
