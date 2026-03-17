import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ptodolist/features/home/views/home_view.dart';
import 'package:ptodolist/features/stats/views/stats_view.dart';
import 'package:ptodolist/features/settings/views/settings_view.dart';
import 'package:ptodolist/features/category/views/category_list_view.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:hive/hive.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) {
                const useMock = String.fromEnvironment('USE_MOCK') == 'true';
                final catRepo = useMock
                    ? CategoryRepository(useMock: true)
                    : CategoryRepository(box: Hive.box<Category>('categories'));
                final routineRepo = useMock
                    ? RoutineRepository(useMock: true)
                    : RoutineRepository(box: Hive.box<Routine>('routines'));
                final taskRepo = useMock
                    ? TaskRepository(useMock: true)
                    : TaskRepository(box: Hive.box<AdditionalTask>('additionalTasks'));
                final dailyRecordRepo = useMock
                    ? DailyRecordRepository(useMock: true)
                    : DailyRecordRepository(box: Hive.box<DailyRecord>('dailyRecords'));
                return HomeView(
                  categoryRepo: catRepo,
                  routineRepo: routineRepo,
                  taskRepo: taskRepo,
                  dailyRecordRepo: dailyRecordRepo,
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsView(),
              routes: [
                GoRoute(
                  path: 'categories',
                  builder: (context, state) {
                    const useMock = String.fromEnvironment('USE_MOCK') == 'true';
                    final repo = useMock
                        ? CategoryRepository(useMock: true)
                        : CategoryRepository(box: Hive.box<Category>('categories'));
                    return CategoryListView(repository: repo);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: '오늘',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: '통계',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
