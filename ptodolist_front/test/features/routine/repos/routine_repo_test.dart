import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';

void main() {
  group('RoutineRepository (Mock)', () {
    late RoutineRepository repo;

    setUp(() {
      repo = RoutineRepository(useMock: true);
    });

    test('Mock 루틴 8개가 반환된다', () {
      expect(repo.getAll().length, 8);
    });

    test('활성 루틴만 필터한다', () {
      final active = repo.getActive();
      expect(active.length, 8); // 기본 전부 active
    });

    test('루틴을 추가한다', () {
      final id = repo.add(title: '새 루틴', categoryId: 'cat-1');
      expect(repo.getAll().length, 9);
      expect(repo.getById(id)!.title, '새 루틴');
    });

    test('루틴을 수정한다', () {
      final original = repo.getById('r-1')!;
      repo.update(original.copyWith(title: '저녁 운동'));
      expect(repo.getById('r-1')!.title, '저녁 운동');
    });

    test('루틴을 비활성화한다', () {
      final original = repo.getById('r-1')!;
      repo.update(original.copyWith(isActive: false));
      expect(repo.getActive().length, 7);
    });

    test('루틴을 삭제한다', () {
      expect(repo.delete('r-1'), true);
      expect(repo.getAll().length, 7);
    });

    test('카테고리 재할당한다', () {
      repo.reassignCategory('cat-1', 'cat-5');
      final reassigned = repo.getAll().where((r) => r.categoryId == 'cat-5');
      // r-1(운동), r-7(운동) → cat-5로 이동
      expect(reassigned.length, greaterThanOrEqualTo(2));
    });

    test('subtasks와 함께 루틴을 추가한다', () {
      final id = repo.add(
        title: '운동 루틴',
        categoryId: 'cat-1',
        subtasks: ['스트레칭', '러닝'],
      );
      final routine = repo.getById(id)!;
      expect(routine.subtasks, ['스트레칭', '러닝']);
    });

    test('subtasks를 수정한다', () {
      final original = repo.getById('r-1')!;
      repo.update(original.copyWith(subtasks: ['팔굽혀펴기', '윗몸일으키기']));
      expect(repo.getById('r-1')!.subtasks, ['팔굽혀펴기', '윗몸일으키기']);
    });

    test('priority와 iconCodePoint로 루틴을 추가한다', () {
      final id = repo.add(
        title: '중요 루틴',
        categoryId: 'cat-1',
        priority: 2,
        iconCodePoint: 0xe613,
      );
      final routine = repo.getById(id)!;
      expect(routine.priority, 2);
      expect(routine.iconCodePoint, 0xe613);
    });

    test('priority를 수정한다', () {
      final original = repo.getById('r-1')!;
      repo.update(original.copyWith(priority: 0));
      expect(repo.getById('r-1')!.priority, 0);
    });
  });
}
