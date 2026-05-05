import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';

void main() {
  group('TaskRepository (Mock)', () {
    late TaskRepository repo;

    setUp(() {
      repo = TaskRepository(useMock: true);
    });

    test('Mock 할 일 3개가 반환된다', () async {
      expect(repo.getAll().length, 3);
    });

    test('날짜별 필터한다', () async {
      final tasks = repo.getByDate('2026-03-17');
      expect(tasks.length, 3);
    });

    test('할 일을 추가한다', () async {
      final id = await repo.add(
        title: '새 할 일',
        categoryId: 'cat-1',
        targetDate: '2026-03-17',
      );
      expect(repo.getAll().length, 4);
      expect(repo.getById(id)!.title, '새 할 일');
    });

    test('완료 토글한다', () async {
      await repo.toggleComplete('t-1');
      expect(repo.getById('t-1')!.isCompleted, true);

      await repo.toggleComplete('t-1');
      expect(repo.getById('t-1')!.isCompleted, false);
    });

    test('이미 완료된 항목을 미완료로 토글한다', () async {
      expect(repo.getById('t-2')!.isCompleted, true);
      await repo.toggleComplete('t-2');
      expect(repo.getById('t-2')!.isCompleted, false);
    });

    test('할 일을 삭제한다', () async {
      expect(await repo.delete('t-1'), true);
      expect(repo.getAll().length, 2);
    });

    test('카테고리 재할당한다', () async {
      await repo.reassignCategory('cat-4', 'cat-5');
      final reassigned = repo.getAll().where((t) => t.categoryId == 'cat-5');
      expect(reassigned.length, 2); // t-1, t-3
    });

    test('subtasks와 함께 할 일을 추가한다', () async {
      final id = await repo.add(
        title: '장보기',
        categoryId: 'cat-4',
        targetDate: '2026-03-17',
        subtasks: ['우유', '계란'],
      );
      final task = repo.getById(id)!;
      expect(task.subtasks, ['우유', '계란']);
    });

    test('subtasks를 수정한다', () async {
      final original = repo.getById('t-1')!;
      await repo.update(original.copyWith(subtasks: ['빵', '버터']));
      expect(repo.getById('t-1')!.subtasks, ['빵', '버터']);
    });

    test('getOverdue: 미완료 + 지난 날짜만 반환한다', () async {
      // 기존 mock은 '2026-03-17', 오늘이 '2026-03-19'이면 overdue
      final overdue = repo.getOverdue('2026-03-19');
      // t-1(미완료), t-3(미완료)는 overdue, t-2(완료)는 아님
      expect(overdue.length, 2);
      expect(overdue.every((t) => !t.isCompleted), true);
      expect(
        overdue.every((t) => t.targetDate.compareTo('2026-03-19') < 0),
        true,
      );
    });

    test('getOverdue: 오늘 이후 날짜는 포함 안 됨', () async {
      await repo.add(title: '미래 할일', categoryId: 'cat-1', targetDate: '2026-03-20');
      final overdue = repo.getOverdue('2026-03-19');
      expect(overdue.any((t) => t.title == '미래 할일'), false);
    });

    test('getTodayAndOverdue: 오늘 할일 + overdue 통합 반환', () async {
      await repo.add(title: '오늘 할일', categoryId: 'cat-1', targetDate: '2026-03-19');
      final tasks = repo.getTodayAndOverdue('2026-03-19');
      // overdue(t-1, t-3) + today(오늘 할일) = 3개
      expect(tasks.length, 3);
    });

    group('getUpcoming', () {
      test('미래 할일만 반환한다 (오늘/과거 제외)', () async {
        // 기존 mock은 targetDate = '2026-03-17'
        await repo.add(
          title: '내일 할일',
          categoryId: 'cat-1',
          targetDate: '2026-03-18',
        );
        await repo.add(
          title: '다음주 할일',
          categoryId: 'cat-1',
          targetDate: '2026-03-24',
        );
        final upcoming = repo.getUpcoming('2026-03-17');
        expect(upcoming.length, 2);
        expect(upcoming.every((t) => t.targetDate.compareTo('2026-03-17') > 0),
            true);
      });

      test('targetDate 오름차순 정렬된다', () async {
        await repo.add(
          title: 'B',
          categoryId: 'cat-1',
          targetDate: '2026-03-25',
        );
        await repo.add(
          title: 'A',
          categoryId: 'cat-1',
          targetDate: '2026-03-20',
        );
        final upcoming = repo.getUpcoming('2026-03-17');
        expect(upcoming.map((t) => t.title).toList(), ['A', 'B']);
      });

      test('미래 할일이 없으면 빈 리스트', () async {
        final upcoming = repo.getUpcoming('2030-01-01');
        expect(upcoming, isEmpty);
      });
    });

    group('toggleSubtask', () {
      test('서브태스크 개별 토글', () async {
        final id = await repo.add(
          title: '장보기',
          categoryId: 'cat-1',
          targetDate: '2026-03-17',
          subtasks: ['우유', '계란', '빵'],
        );
        await repo.toggleSubtask(id, 1);
        final task = repo.getById(id)!;
        expect(task.isSubtaskCompleted(0), false);
        expect(task.isSubtaskCompleted(1), true);
        expect(task.isSubtaskCompleted(2), false);
        expect(task.isCompleted, false);
      });

      test('모든 서브태스크 완료 시 상위도 자동 완료', () async {
        final id = await repo.add(
          title: '장보기',
          categoryId: 'cat-1',
          targetDate: '2026-03-17',
          subtasks: ['우유', '계란'],
        );
        await repo.toggleSubtask(id, 0);
        expect(repo.getById(id)!.isCompleted, false);
        await repo.toggleSubtask(id, 1);
        expect(repo.getById(id)!.isCompleted, true);
      });

      test('한 개 해제 시 상위 완료가 해제된다', () async {
        final id = await repo.add(
          title: '장보기',
          categoryId: 'cat-1',
          targetDate: '2026-03-17',
          subtasks: ['우유', '계란'],
        );
        await repo.toggleSubtask(id, 0);
        await repo.toggleSubtask(id, 1);
        expect(repo.getById(id)!.isCompleted, true);
        await repo.toggleSubtask(id, 0);
        expect(repo.getById(id)!.isCompleted, false);
      });

      test('잘못된 인덱스는 무시된다', () async {
        final id = await repo.add(
          title: '장보기',
          categoryId: 'cat-1',
          targetDate: '2026-03-17',
          subtasks: ['우유'],
        );
        await repo.toggleSubtask(id, 5);
        await repo.toggleSubtask(id, -1);
        expect(repo.getById(id)!.subtaskCompletions, isEmpty);
      });

      test('상위 토글 시 모든 서브태스크도 동기화된다', () async {
        final id = await repo.add(
          title: '장보기',
          categoryId: 'cat-1',
          targetDate: '2026-03-17',
          subtasks: ['우유', '계란'],
        );
        await repo.toggleComplete(id);
        final task = repo.getById(id)!;
        expect(task.isCompleted, true);
        expect(task.isSubtaskCompleted(0), true);
        expect(task.isSubtaskCompleted(1), true);
      });
    });
  });
}
