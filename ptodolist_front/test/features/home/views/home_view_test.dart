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

    testWidgets('루틴 탭이 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 3탭 라벨 확인
      expect(find.text('루틴'), findsWidgets);
      expect(find.text('오늘'), findsWidgets);
      expect(find.text('예정'), findsWidgets);
    });

    testWidgets('Mock 루틴들이 표시된다 (루틴 탭 기본 노출)', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('아침 운동'), findsOneWidget);
      expect(find.text('영어 공부'), findsOneWidget);
    });

    testWidgets('오늘 탭으로 이동하면 할일이 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('오늘').first);
      await tester.pumpAndSettle();
      expect(find.text('오늘 할 일'), findsOneWidget);
    });

    testWidgets('진행률 링이 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 진행률 링: 퍼센트 표시 (헤더는 expanded/compact 두 레이어가 공존)
      expect(find.textContaining('%'), findsWidgets);
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

    testWidgets('빈 상태에서는 각 탭 별 EmptyState가 표시된다', (tester) async {
      final emptyRoutineRepo = RoutineRepository(useMock: true);
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

      // 기본 탭(루틴) 빈 상태
      expect(find.text('오늘 루틴 없음'), findsOneWidget);
    });
  });
}
