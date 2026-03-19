import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/home_widget/services/home_widget_service.dart';

class MidnightResetService with WidgetsBindingObserver {
  final DailyRecordRepository dailyRecordRepo;
  final RoutineRepository routineRepo;
  final VoidCallback? onDayChanged;
  final HomeWidgetService? homeWidgetService;

  Timer? _timer;
  String _lastKnownDate;

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  MidnightResetService({
    required this.dailyRecordRepo,
    required this.routineRepo,
    this.onDayChanged,
    this.homeWidgetService,
  }) : _lastKnownDate = _dateFmt.format(DateTime.now());

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _ensureTodayRecord();
    _startTimer();
  }

  void stop() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  // 시나리오 B: 백그라운드 복귀
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDateChange();
    }
  }

  // 시나리오 A: 포그라운드 자정 넘김
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      _checkDateChange();
    });
  }

  void _checkDateChange() {
    final today = _dateFmt.format(DateTime.now());
    if (today != _lastKnownDate) {
      _lastKnownDate = today;
      _ensureTodayRecord();
      homeWidgetService?.updateWidgetData();
      onDayChanged?.call();
    }
  }

  // 시나리오 C: 앱 실행 시
  DailyRecord _ensureTodayRecord() {
    final activeRoutines = routineRepo.getActive();
    return dailyRecordRepo.getOrCreateToday(activeRoutines);
  }

  DailyRecord getCurrentRecord() {
    return _ensureTodayRecord();
  }
}
