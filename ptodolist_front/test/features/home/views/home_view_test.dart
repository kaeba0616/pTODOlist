import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/home/views/home_view.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  group('HomeView', () {
    late CategoryRepository catRepo;
    late RoutineRepository routineRepo;
    late TaskRepository taskRepo;

    setUp(() {
      catRepo = CategoryRepository(useMock: true);
      routineRepo = RoutineRepository(useMock: true);
      taskRepo = TaskRepository(useMock: true);
      // 오늘 날짜의 할 일 추가
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      taskRepo.add(title: '오늘 할 일', categoryId: 'cat-4', targetDate: today);
    });

    Widget buildTestWidget() {
      return MaterialApp(
        home: HomeView(
          categoryRepo: catRepo,
          routineRepo: routineRepo,
          taskRepo: taskRepo,
        ),
      );
    }

    testWidgets('루틴 섹션이 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('오늘의 루틴'), findsOneWidget);
    });

    testWidgets('Mock 루틴들이 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('아침 운동'), findsOneWidget);
      expect(find.text('영어 공부'), findsOneWidget);
    });

    testWidgets('추가 할 일 섹션이 표시된다 (스크롤 후)', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 루틴이 8개라 스크롤 필요
      await tester.scrollUntilVisible(find.text('추가 할 일'), 200);
      expect(find.text('추가 할 일'), findsOneWidget);
    });

    testWidgets('진행률 링이 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 초기 상태: 0% (mock tasks 중 1개 완료)
      expect(find.textContaining('완료'), findsOneWidget);
    });

    testWidgets('FAB이 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB 탭하면 추가 선택 시트가 열린다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('루틴 추가'), findsOneWidget);
      expect(find.text('할 일 추가'), findsOneWidget);
    });

    testWidgets('빈 상태에서는 EmptyState가 표시된다', (tester) async {
      // 빈 레포로 생성
      final emptyRoutineRepo = RoutineRepository(useMock: true);
      // mock 데이터를 비우기 위해 모두 삭제
      for (final r in emptyRoutineRepo.getAll().toList()) {
        emptyRoutineRepo.delete(r.id);
      }
      final emptyTaskRepo = TaskRepository(useMock: true);
      for (final t in emptyTaskRepo.getAll().toList()) {
        emptyTaskRepo.delete(t.id);
      }

      await tester.pumpWidget(
        MaterialApp(
          home: HomeView(
            categoryRepo: catRepo,
            routineRepo: emptyRoutineRepo,
            taskRepo: emptyTaskRepo,
          ),
        ),
      );

      expect(find.text('아직 할 일이 없어요'), findsOneWidget);
    });
  });
}
