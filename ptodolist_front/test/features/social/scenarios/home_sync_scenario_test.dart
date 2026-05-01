import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/home/views/home_view.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/social/providers/social_providers.dart';
import 'package:ptodolist/features/social/services/daily_share_sync_service.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';

/// 호출 로그를 남기고 미리 정한 결과를 돌려주는 fake.
class _RecordingSyncService implements DailyShareSyncService {
  final List<({DailyRecord record, List<Routine> routines})> calls = [];
  SyncResult Function() nextResult = () => const SyncedOk('test-doc');

  @override
  Future<SyncResult> syncToday({
    required DailyRecord record,
    required List<Routine> activeRoutines,
  }) async {
    calls.add((record: record, routines: activeRoutines));
    return nextResult();
  }
}

Widget _wrap(Widget child, _RecordingSyncService fake) {
  return ProviderScope(
    overrides: [
      dailyShareSyncServiceProvider.overrideWithValue(fake),
    ],
    child: MaterialApp(home: child),
  );
}

HomeView _homeView() {
  return HomeView(
    categoryRepo: CategoryRepository(useMock: true),
    routineRepo: RoutineRepository(useMock: true),
    taskRepo: TaskRepository(useMock: true),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  group('User scenario: 홈 진입 시 자동 sync', () {
    testWidgets('앱 시작 시 postFrameCallback 으로 syncToday 1회 호출', (tester) async {
      final fake = _RecordingSyncService();
      await tester.pumpWidget(_wrap(_homeView(), fake));
      await tester.pumpAndSettle();

      expect(fake.calls.length, 1);
      // 첫 호출 시 record 의 date 는 오늘이어야 함
      expect(fake.calls.first.record.date.length, 10); // yyyy-MM-dd
      // mock 루틴 2개 있음 (아침 운동, 영어 공부)
      expect(fake.calls.first.routines.length, greaterThanOrEqualTo(1));
    });

    testWidgets('성공 결과면 SnackBar 안 뜸 (조용한 동기화)', (tester) async {
      final fake = _RecordingSyncService()
        ..nextResult = () => const SyncedOk('uid_2026-05-02');
      await tester.pumpWidget(_wrap(_homeView(), fake));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('실패 결과면 SnackBar 로 에러 노출', (tester) async {
      final fake = _RecordingSyncService()
        ..nextResult = () =>
            SyncedFailed(Exception('PERMISSION_DENIED'), StackTrace.empty);
      await tester.pumpWidget(_wrap(_homeView(), fake));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('동기화 실패'), findsOneWidget);
      expect(find.textContaining('PERMISSION_DENIED'), findsOneWidget);
    });

    testWidgets('비로그인이면 SnackBar 안 뜸 (조용한 스킵)', (tester) async {
      final fake = _RecordingSyncService()
        ..nextResult = () => const SyncedSkipped('no-user');
      await tester.pumpWidget(_wrap(_homeView(), fake));
      await tester.pumpAndSettle();

      // initState 의 postFrameCallback 은 SyncedFailed 일 때만 SnackBar 뜸
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('User scenario: 루틴 토글 → sync 트리거', () {
    testWidgets('루틴 체크박스를 탭하면 syncToday 가 한 번 더 호출됨', (tester) async {
      final fake = _RecordingSyncService();
      await tester.pumpWidget(_wrap(_homeView(), fake));
      await tester.pumpAndSettle();

      // 초기 sync 1회
      expect(fake.calls.length, 1);

      // 첫 번째 루틴(r-1: '아침 운동') 의 토글 체크박스 탭
      final toggle = find.byKey(const Key('routine-toggle-r-1'));
      expect(toggle, findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      // 토글 후 sync 다시 호출
      expect(fake.calls.length, greaterThanOrEqualTo(2));
    });

    testWidgets('토글 후 성공 SnackBar 가 표시됨', (tester) async {
      final fake = _RecordingSyncService()
        ..nextResult = () => const SyncedOk('uid_2026-05-02');
      await tester.pumpWidget(_wrap(_homeView(), fake));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('routine-toggle-r-1')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('✓ 동기화'), findsOneWidget);
    });

    testWidgets('토글 후 publicMode off 결과면 삭제 SnackBar', (tester) async {
      final fake = _RecordingSyncService()
        ..nextResult = () => const SyncedDeleted();
      await tester.pumpWidget(_wrap(_homeView(), fake));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('routine-toggle-r-1')));
      await tester.pumpAndSettle();

      expect(find.textContaining('비공개 모드'), findsOneWidget);
    });

    testWidgets('토글 후 no-profile 스킵 SnackBar', (tester) async {
      final fake = _RecordingSyncService()
        ..nextResult = () => const SyncedSkipped('no-profile');
      await tester.pumpWidget(_wrap(_homeView(), fake));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('routine-toggle-r-1')));
      await tester.pumpAndSettle();

      expect(find.textContaining('동기화 스킵: no-profile'), findsOneWidget);
    });
  });
}
