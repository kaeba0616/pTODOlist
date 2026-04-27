import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ptodolist/core/theme/app_theme.dart';
import 'package:ptodolist/core/router/app_router.dart';
import 'package:ptodolist/core/db/database_service.dart';
import 'package:ptodolist/core/services/notification_service.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/home_widget/services/home_widget_service.dart';

HomeWidgetService? _homeWidgetService;

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
  }

  runApp(const ProviderScope(child: PtodolistApp()));
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
