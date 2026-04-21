import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';

/// 로컬 Hive 데이터를 JSON으로 백업/복원한다.
///
/// 스키마 버전 1:
/// {
///   "version": 1,
///   "exportedAt": "2026-04-15T12:34:56.000",
///   "data": {
///     "categories": [...],
///     "routines": [...],
///     "additionalTasks": [...],
///     "dailyRecords": [...],
///     "appSettings": { ... }
///   }
/// }
class BackupService {
  static const int schemaVersion = 1;

  Box<Category> get _categoriesBox => Hive.box<Category>('categories');
  Box<Routine> get _routinesBox => Hive.box<Routine>('routines');
  Box<AdditionalTask> get _tasksBox => Hive.box<AdditionalTask>('additionalTasks');
  Box<DailyRecord> get _dailyRecordsBox => Hive.box<DailyRecord>('dailyRecords');
  Box get _settingsBox => Hive.box('appSettings');

  String exportToJson() {
    final payload = {
      'version': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': {
        'categories': _categoriesBox.values.map(_categoryToMap).toList(),
        'routines': _routinesBox.values.map(_routineToMap).toList(),
        'additionalTasks': _tasksBox.values.map(_taskToMap).toList(),
        'dailyRecords': _dailyRecordsBox.values.map(_dailyRecordToMap).toList(),
        'appSettings': {
          'notificationEnabled':
              _settingsBox.get('notificationEnabled', defaultValue: true),
          'notificationTime':
              _settingsBox.get('notificationTime', defaultValue: '23:00'),
          'retentionMonths':
              _settingsBox.get('retentionMonths', defaultValue: 6),
          'themeMode': _settingsBox.get('themeMode', defaultValue: 'system'),
        },
      },
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> importFromJson(String json) async {
    final Map<String, dynamic> payload = jsonDecode(json);
    final version = payload['version'];
    if (version is! int || version > schemaVersion) {
      throw StateError('지원하지 않는 백업 버전입니다: $version');
    }
    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('백업 파일 형식이 올바르지 않습니다.');
    }

    await _categoriesBox.clear();
    for (final entry in (data['categories'] as List? ?? const [])) {
      final c = _categoryFromMap(entry as Map<String, dynamic>);
      await _categoriesBox.put(c.id, c);
    }

    await _routinesBox.clear();
    for (final entry in (data['routines'] as List? ?? const [])) {
      final r = _routineFromMap(entry as Map<String, dynamic>);
      await _routinesBox.put(r.id, r);
    }

    await _tasksBox.clear();
    for (final entry in (data['additionalTasks'] as List? ?? const [])) {
      final t = _taskFromMap(entry as Map<String, dynamic>);
      await _tasksBox.put(t.id, t);
    }

    await _dailyRecordsBox.clear();
    for (final entry in (data['dailyRecords'] as List? ?? const [])) {
      final d = _dailyRecordFromMap(entry as Map<String, dynamic>);
      await _dailyRecordsBox.put(d.date, d);
    }

    final settings = data['appSettings'];
    if (settings is Map<String, dynamic>) {
      await _settingsBox.put(
          'notificationEnabled', settings['notificationEnabled'] ?? true);
      await _settingsBox.put(
          'notificationTime', settings['notificationTime'] ?? '23:00');
      await _settingsBox.put(
          'retentionMonths', settings['retentionMonths'] ?? 6);
      await _settingsBox.put('themeMode', settings['themeMode'] ?? 'system');
    }
  }

  Future<File> writeExportToFile() async {
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
    final file = File('${dir.path}/ptodolist-backup-$stamp.json');
    return file.writeAsString(exportToJson());
  }

  // ---------- Category ----------
  Map<String, dynamic> _categoryToMap(Category c) => {
        'id': c.id,
        'name': c.name,
        'color': c.color,
        'icon': c.icon,
      };

  Category _categoryFromMap(Map<String, dynamic> m) => Category(
        id: m['id'] as String,
        name: m['name'] as String,
        color: m['color'] as String,
        icon: m['icon'] as String?,
      );

  // ---------- Routine ----------
  Map<String, dynamic> _routineToMap(Routine r) => {
        'id': r.id,
        'title': r.title,
        'categoryId': r.categoryId,
        'createdAt': r.createdAt.toIso8601String(),
        'isActive': r.isActive,
        'order': r.order,
        'subtasks': r.subtasks,
        'priority': r.priority,
        'iconCodePoint': r.iconCodePoint,
        'activeDays': r.activeDays,
        'deletedAt': r.deletedAt,
      };

  Routine _routineFromMap(Map<String, dynamic> m) => Routine(
        id: m['id'] as String,
        title: m['title'] as String,
        categoryId: m['categoryId'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
        isActive: (m['isActive'] as bool?) ?? true,
        order: (m['order'] as int?) ?? 0,
        subtasks: List<String>.from(m['subtasks'] as List? ?? const []),
        priority: (m['priority'] as int?) ?? 1,
        iconCodePoint: m['iconCodePoint'] as int?,
        activeDays: List<int>.from(m['activeDays'] as List? ?? const []),
        deletedAt: m['deletedAt'] as String?,
      );

  // ---------- AdditionalTask ----------
  Map<String, dynamic> _taskToMap(AdditionalTask t) => {
        'id': t.id,
        'title': t.title,
        'categoryId': t.categoryId,
        'createdAt': t.createdAt.toIso8601String(),
        'targetDate': t.targetDate,
        'isCompleted': t.isCompleted,
        'order': t.order,
        'subtasks': t.subtasks,
        'subtaskCompletions': t.subtaskCompletions,
      };

  AdditionalTask _taskFromMap(Map<String, dynamic> m) => AdditionalTask(
        id: m['id'] as String,
        title: m['title'] as String,
        categoryId: m['categoryId'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
        targetDate: m['targetDate'] as String,
        isCompleted: (m['isCompleted'] as bool?) ?? false,
        order: (m['order'] as int?) ?? 0,
        subtasks: List<String>.from(m['subtasks'] as List? ?? const []),
        subtaskCompletions:
            List<bool>.from(m['subtaskCompletions'] as List? ?? const []),
      );

  // ---------- DailyRecord ----------
  Map<String, dynamic> _dailyRecordToMap(DailyRecord d) => {
        'date': d.date,
        'routineCompletions': d.routineCompletions,
      };

  DailyRecord _dailyRecordFromMap(Map<String, dynamic> m) => DailyRecord(
        date: m['date'] as String,
        routineCompletions: Map<String, bool>.from(
          (m['routineCompletions'] as Map?) ?? const {},
        ),
      );
}
