import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';

class HomeWidgetService {
  final DailyRecordRepository dailyRecordRepo;
  final RoutineRepository routineRepo;

  static const _maxDisplayRoutines = 5;
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  HomeWidgetService({
    required this.dailyRecordRepo,
    required this.routineRepo,
  });

  /// 위젯에 표시할 데이터를 빌드한다
  Map<String, dynamic> buildWidgetData() {
    final today = _dateFmt.format(DateTime.now());
    final weekday = DateTime.now().weekday;
    final activeRoutines = routineRepo.getActiveForDay(weekday);
    final record = dailyRecordRepo.get(today);

    final routineItems = <Map<String, dynamic>>[];
    for (final routine in activeRoutines.take(_maxDisplayRoutines)) {
      routineItems.add({
        'id': routine.id,
        'title': routine.title,
        'isDone': record?.isRoutineCompleted(routine.id) ?? false,
      });
    }

    final completedCount = record?.completedCount ?? 0;
    final totalCount = activeRoutines.length;
    final remainingCount = totalCount > _maxDisplayRoutines
        ? totalCount - _maxDisplayRoutines
        : 0;

    return {
      'date': today,
      'completedCount': completedCount,
      'totalCount': totalCount,
      'remainingCount': remainingCount,
      'routines': routineItems,
    };
  }

  /// 위젯의 체크박스 탭 시 루틴을 토글한다
  void handleToggleAction(String routineId) {
    final today = _dateFmt.format(DateTime.now());
    final activeRoutines = routineRepo.getActiveForDay(DateTime.now().weekday);
    dailyRecordRepo.toggleRoutineCompletion(today, routineId, activeRoutines);
  }

  /// 위젯 데이터를 SharedPreferences에 저장하고 위젯을 갱신한다
  Future<void> updateWidgetData() async {
    final data = buildWidgetData();

    await HomeWidget.saveWidgetData<String>('date', data['date']);
    await HomeWidget.saveWidgetData<int>(
        'completedCount', data['completedCount']);
    await HomeWidget.saveWidgetData<int>('totalCount', data['totalCount']);
    await HomeWidget.saveWidgetData<int>(
        'remainingCount', data['remainingCount']);
    await HomeWidget.saveWidgetData<String>(
        'routines', jsonEncode(data['routines']));

    await HomeWidget.updateWidget(
      androidName: 'PtodolistWidgetProvider',
    );
  }

  /// home_widget 콜백 URI를 처리한다
  Future<void> handleWidgetCallback(Uri? uri) async {
    if (uri == null) return;

    if (uri.host == 'toggle') {
      final routineId = uri.queryParameters['routineId'];
      if (routineId != null) {
        handleToggleAction(routineId);
        await updateWidgetData();
      }
    }
  }
}
