import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/home/views/home_view.dart';
import 'package:ptodolist/features/stats/views/stats_view.dart';
import 'package:ptodolist/features/settings/views/settings_view.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';
import 'package:ptodolist/core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  group('App Navigation', () {
    testWidgets('바텀 네비게이션 탭 전환이 동작한다', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: StatefulBuilder(
            builder: (context, setState) {
              final screens = [
                HomeView(
                  categoryRepo: CategoryRepository(useMock: true),
                  routineRepo: RoutineRepository(useMock: true),
                  taskRepo: TaskRepository(useMock: true),
                ),
                const StatsView(),
                const SettingsView(),
              ];
              return Scaffold(
                body: screens[selectedIndex],
                bottomNavigationBar: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (i) =>
                      setState(() => selectedIndex = i),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      label: '오늘',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      label: '통계',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      label: '설정',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 홈 탭 (기본): 3탭 라벨 중 '루틴' 존재 확인
      expect(find.text('루틴'), findsWidgets);
      expect(find.text('오늘'), findsWidgets);
      expect(find.text('예정'), findsWidgets);

      // 통계 탭
      await tester.tap(find.text('통계'));
      await tester.pumpAndSettle();
      expect(find.text('달성률 통계'), findsOneWidget);

      // 설정 탭
      await tester.tap(find.text('설정').last);
      await tester.pumpAndSettle();
      expect(find.text('카테고리 관리'), findsOneWidget);
    });
  });
}
