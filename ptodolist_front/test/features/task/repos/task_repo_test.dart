import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';

void main() {
  group('TaskRepository (Mock)', () {
    late TaskRepository repo;

    setUp(() {
      repo = TaskRepository(useMock: true);
    });

    test('Mock 할 일 3개가 반환된다', () {
      expect(repo.getAll().length, 3);
    });

    test('날짜별 필터한다', () {
      final tasks = repo.getByDate('2026-03-17');
      expect(tasks.length, 3);
    });

    test('할 일을 추가한다', () {
      final id = repo.add(
        title: '새 할 일',
        categoryId: 'cat-1',
        targetDate: '2026-03-17',
      );
      expect(repo.getAll().length, 4);
      expect(repo.getById(id)!.title, '새 할 일');
    });

    test('완료 토글한다', () {
      repo.toggleComplete('t-1');
      expect(repo.getById('t-1')!.isCompleted, true);

      repo.toggleComplete('t-1');
      expect(repo.getById('t-1')!.isCompleted, false);
    });

    test('이미 완료된 항목을 미완료로 토글한다', () {
      expect(repo.getById('t-2')!.isCompleted, true);
      repo.toggleComplete('t-2');
      expect(repo.getById('t-2')!.isCompleted, false);
    });

    test('할 일을 삭제한다', () {
      expect(repo.delete('t-1'), true);
      expect(repo.getAll().length, 2);
    });

    test('카테고리 재할당한다', () {
      repo.reassignCategory('cat-4', 'cat-5');
      final reassigned = repo.getAll().where((t) => t.categoryId == 'cat-5');
      expect(reassigned.length, 2); // t-1, t-3
    });

    test('subtasks와 함께 할 일을 추가한다', () {
      final id = repo.add(
        title: '장보기',
        categoryId: 'cat-4',
        targetDate: '2026-03-17',
        subtasks: ['우유', '계란'],
      );
      final task = repo.getById(id)!;
      expect(task.subtasks, ['우유', '계란']);
    });

    test('subtasks를 수정한다', () {
      final original = repo.getById('t-1')!;
      repo.update(original.copyWith(subtasks: ['빵', '버터']));
      expect(repo.getById('t-1')!.subtasks, ['빵', '버터']);
    });
  });
}
