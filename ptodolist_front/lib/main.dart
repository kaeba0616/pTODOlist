import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ptodolist/core/auth/current_user.dart';
import 'package:ptodolist/core/theme/app_theme.dart';
import 'package:ptodolist/core/router/app_router.dart';
import 'package:ptodolist/core/db/database_service.dart';
import 'package:ptodolist/core/services/notification_service.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/sync/services/cloud_sync_service.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';
import 'package:ptodolist/features/home_widget/services/home_widget_service.dart';

HomeWidgetService? _homeWidgetService;
CloudSyncService? _cloudSync;

/// 디버그/강제동기화용 외부 접근.
CloudSyncService? get cloudSyncService => _cloudSync;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  const useMock = String.fromEnvironment('USE_MOCK') == 'true';

  if (!useMock) {
    await DatabaseService.init();
    await NotificationService.init();

    // Firebase 초기화 (Android: google-services.json 자동 로드)
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase init failed (offline?): $e');
    }

    // Home Widget 초기화
    _homeWidgetService = HomeWidgetService(
      dailyRecordRepo: DailyRecordRepository(
        box: Hive.box<DailyRecord>('dailyRecords'),
      ),
      routineRepo: RoutineRepository(
        box: Hive.box<Routine>('routines'),
      ),
    );
    HomeWidget.registerInteractivityCallback(backgroundCallback);
    await _homeWidgetService!.updateWidgetData();

    // Cloud Sync 서비스 (auth listener 에서 사용)
    _cloudSync = CloudSyncService(
      routineRepo: RoutineRepository(box: Hive.box<Routine>('routines')),
      categoryRepo:
          CategoryRepository(box: Hive.box<Category>('categories')),
      taskRepo:
          TaskRepository(box: Hive.box<AdditionalTask>('additionalTasks')),
      dailyRecordRepo:
          DailyRecordRepository(box: Hive.box<DailyRecord>('dailyRecords')),
    );

    // 로그인/로그아웃/계정전환 자동 감지 → 로컬 swap
    _wireAuthListener();
  }

  runApp(const ProviderScope(child: PtodolistApp()));
}

void _wireAuthListener() {
  final settingsBox = Hive.box('appSettings');
  String? lastUid = settingsBox.get('lastSignedInUid') as String?;
  // 앱 시작 시 이미 로그인 상태면 CurrentUser 채워서 push-through 활성화
  final initialUser = FirebaseAuth.instance.currentUser;
  if (initialUser != null) {
    CurrentUser.uid = initialUser.uid;
  }

  FirebaseAuth.instance.authStateChanges().listen((user) async {
    final newUid = user?.uid;
    if (newUid == lastUid) {
      // 같은 사용자 재로그인 (또는 시작 시 같은 uid) → push-through 활성화만
      CurrentUser.uid = newUid;
      return;
    }
    if (newUid == null) {
      // 로그아웃: 로컬 wipe
      debugPrint('[auth] logout — wiping local');
      CurrentUser.uid = null;
      await _cloudSync?.wipeLocal();
      lastUid = null;
      await settingsBox.delete('lastSignedInUid');
    } else {
      // 다른 계정으로 로그인 → wipe + pull
      debugPrint('[auth] uid changed: $lastUid → $newUid — wipe+pull');
      CurrentUser.uid = newUid;
      await _cloudSync?.wipeLocal();
      try {
        await _cloudSync?.pullAll(newUid);
      } catch (e) {
        debugPrint('[auth] pullAll failed: $e');
      }
      lastUid = newUid;
      await settingsBox.put('lastSignedInUid', newUid);
    }
  });
}

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (_homeWidgetService != null) {
    await _homeWidgetService!.handleWidgetCallback(uri);
  }
}

class PtodolistApp extends StatefulWidget {
  const PtodolistApp({super.key});

  @override
  State<PtodolistApp> createState() => _PtodolistAppState();
}

class _PtodolistAppState extends State<PtodolistApp> {
  late ThemeMode _themeMode;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _themeMode = _loadThemeMode();
    _router = buildAppRouter(onThemeChanged: _onThemeChanged);
  }

  ThemeMode _loadThemeMode() {
    const useMock = String.fromEnvironment('USE_MOCK') == 'true';
    if (useMock) return ThemeMode.system;
    final box = Hive.box('appSettings');
    final mode = box.get('themeMode', defaultValue: 'system') as String;
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _onThemeChanged(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'pTODOlist',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
