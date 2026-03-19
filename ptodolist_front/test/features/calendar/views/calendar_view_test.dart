import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/features/calendar/views/calendar_view.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  group('CalendarView', () {
    late DailyRecordRepository dailyRecordRepo;
    late RoutineRepository routineRepo;
    late TaskRepository taskRepo;
    late CategoryRepository categoryRepo;

    setUp(() {
      dailyRecordRepo = DailyRecordRepository(useMock: true);
      routineRepo = RoutineRepository(useMock: true);
      taskRepo = TaskRepository(useMock: true);
      categoryRepo = CategoryRepository(useMock: true);

      // Mock 데이터 추가: 오늘의 기록
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final routines = routineRepo.getActive();
      dailyRecordRepo.getOrCreateToday(routines);

      // 어제 기록도 추가
      final yesterday = DateFormat('yyyy-MM-dd').format(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      dailyRecordRepo.save(DailyRecord(
        date: yesterday,
        routineCompletions: {for (final r in routines) r.id: true},
      ));
    });

    Widget buildTestWidget() {
      return MaterialApp(
        home: CalendarView(
          dailyRecordRepo: dailyRecordRepo,
          routineRepo: routineRepo,
          taskRepo: taskRepo,
          categoryRepo: categoryRepo,
        ),
      );
    }

    testWidgets('현재 월/년이 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final now = DateTime.now();
      expect(find.text('${now.year}년 ${now.month}월'), findsOneWidget);
    });

    testWidgets('요일 헤더가 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('월'), findsOneWidget);
      expect(find.text('화'), findsOneWidget);
      expect(find.text('수'), findsOneWidget);
      expect(find.text('목'), findsOneWidget);
      expect(find.text('금'), findsOneWidget);
      expect(find.text('토'), findsOneWidget);
      expect(find.text('일'), findsOneWidget);
    });

    testWidgets('이전 월 버튼을 탭하면 월이 변경된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 이전 월 버튼 탭
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      final now = DateTime.now();
      final prevMonth = DateTime(now.year, now.month - 1);
      expect(
        find.text('${prevMonth.year}년 ${prevMonth.month}월'),
        findsOneWidget,
      );
    });

    testWidgets('다음 월 버튼을 탭하면 월이 변경된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 다음 월 버튼 탭
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      final now = DateTime.now();
      final nextMonth = DateTime(now.year, now.month + 1);
      expect(
        find.text('${nextMonth.year}년 ${nextMonth.month}월'),
        findsOneWidget,
      );
    });

    testWidgets('오늘 날짜가 캘린더에 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final today = DateTime.now().day;
      expect(find.text('$today'), findsOneWidget);
    });

    testWidgets('날짜 셀을 탭하면 바텀시트가 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 어제 날짜 탭 (데이터가 있는 날)
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      // 어제가 이번 달이면 탭
      if (yesterday.month == DateTime.now().month) {
        await tester.tap(find.text('${yesterday.day}').first);
        await tester.pumpAndSettle();

        // 바텀시트에 날짜 정보가 표시됨
        expect(find.text('루틴'), findsWidgets);
      }
    });
  });
}
