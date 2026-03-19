import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/routine/models/routine.dart';

class DailyRecordRepository {
  final bool useMock;
  final Box<DailyRecord>? _box;
  final Map<String, DailyRecord> _mockData = {};

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  DailyRecordRepository({this.useMock = false, Box<DailyRecord>? box})
    : _box = box;

  String get todayKey => _dateFmt.format(DateTime.now());

  DailyRecord? get(String date) {
    if (useMock) return _mockData[date];
    return _box!.get(date);
  }

  DailyRecord getOrCreateToday(List<Routine> activeRoutines) {
    final today = todayKey;
    final existing = get(today);
    if (existing != null) return existing;

    final record = DailyRecord(
      date: today,
      routineCompletions: {for (final r in activeRoutines) r.id: false},
    );
    _put(today, record);
    return record;
  }

  void save(DailyRecord record) {
    _put(record.date, record);
  }

  DailyRecord toggleRoutineCompletion(
    String date,
    String routineId,
    List<Routine> activeRoutines,
  ) {
    final record = get(date) ?? getOrCreateToday(activeRoutines);
    final updated = record.toggleRoutine(routineId);
    save(updated);
    return updated;
  }

  List<DailyRecord> getRecordsInRange(String startDate, String endDate) {
    if (useMock) {
      return _mockData.values
          .where(
            (r) =>
                r.date.compareTo(startDate) >= 0 &&
                r.date.compareTo(endDate) <= 0,
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    return _box!.values
        .where(
          (r) =>
              r.date.compareTo(startDate) >= 0 &&
              r.date.compareTo(endDate) <= 0,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Map<String, double> getCompletionRatesForMonth(int year, int month) {
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(year, month + 1, 0).day;
    final endDate =
        '$year-${month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';
    final records = getRecordsInRange(startDate, endDate);
    return {for (final r in records) r.date: r.completionRate};
  }

  int deleteOlderThan(DateTime cutoff) {
    final cutoffStr = _dateFmt.format(cutoff);
    if (useMock) {
      final keysToRemove = _mockData.keys
          .where((k) => k.compareTo(cutoffStr) < 0)
          .toList();
      for (final key in keysToRemove) {
        _mockData.remove(key);
      }
      return keysToRemove.length;
    }
    final keysToRemove = _box!.keys
        .cast<String>()
        .where((k) => k.compareTo(cutoffStr) < 0)
        .toList();
    for (final key in keysToRemove) {
      _box!.delete(key);
    }
    return keysToRemove.length;
  }

  void _put(String key, DailyRecord record) {
    if (useMock) {
      _mockData[key] = record;
    } else {
      _box!.put(key, record);
    }
  }
}
