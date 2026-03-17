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
      final a = AdditionalTask(id: '1', title: '마트', categoryId: 'cat-4', createdAt: DateTime(2026, 3, 17), targetDate: '2026-03-17');
      final b = AdditionalTask(id: '1', title: '마트', categoryId: 'cat-4', createdAt: DateTime(2026, 3, 17), targetDate: '2026-03-17');

      expect(a, equals(b));
    });
  });
}
