import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ptodolist/core/db/backup_service.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/models/category_adapter.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/home/models/daily_record_adapter.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/routine/models/routine_adapter.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';
import 'package:ptodolist/features/task/models/additional_task_adapter.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('ptodolist_backup_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CategoryAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(RoutineAdapter());
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AdditionalTaskAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(DailyRecordAdapter());
  });

  setUp(() async {
    await Hive.openBox('appSettings');
    await Hive.openBox<Category>('categories');
    await Hive.openBox<Routine>('routines');
    await Hive.openBox<AdditionalTask>('additionalTasks');
    await Hive.openBox<DailyRecord>('dailyRecords');
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('appSettings');
    await Hive.deleteBoxFromDisk('categories');
    await Hive.deleteBoxFromDisk('routines');
    await Hive.deleteBoxFromDisk('additionalTasks');
    await Hive.deleteBoxFromDisk('dailyRecords');
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('export → clear → import 왕복 동일성', () async {
    final service = BackupService();

    final category = Category(
      id: 'c-1',
      name: '운동',
      color: '#FF0000',
      icon: null,
    );
    final routine = Routine(
      id: 'r-1',
      title: '스트레칭',
      categoryId: 'c-1',
      createdAt: DateTime(2026, 3, 1, 9),
      isActive: true,
      order: 0,
      subtasks: const ['목', '허리'],
      priority: 2,
      iconCodePoint: 0xe613,
      activeDays: const [1, 3, 5],
      deletedAt: null,
    );
    final task = AdditionalTask(
      id: 't-1',
      title: '장보기',
      categoryId: 'c-1',
      createdAt: DateTime(2026, 3, 2, 10),
      targetDate: '2026-03-17',
      isCompleted: false,
      order: 0,
      subtasks: const ['우유', '계란'],
      subtaskCompletions: const [true, false],
    );
    final record = DailyRecord(
      date: '2026-03-17',
      routineCompletions: const {'r-1': true},
    );

    await Hive.box<Category>('categories').put(category.id, category);
    await Hive.box<Routine>('routines').put(routine.id, routine);
    await Hive.box<AdditionalTask>('additionalTasks').put(task.id, task);
    await Hive.box<DailyRecord>('dailyRecords').put(record.date, record);
    await Hive.box('appSettings').put('notificationEnabled', false);
    await Hive.box('appSettings').put('themeMode', 'dark');

    final json = service.exportToJson();
    expect(json, contains('"version": 1'));
    expect(json, contains('스트레칭'));

    await Hive.box<Category>('categories').clear();
    await Hive.box<Routine>('routines').clear();
    await Hive.box<AdditionalTask>('additionalTasks').clear();
    await Hive.box<DailyRecord>('dailyRecords').clear();
    await Hive.box('appSettings').clear();

    await service.importFromJson(json);

    expect(Hive.box<Category>('categories').get('c-1'), category);
    expect(Hive.box<Routine>('routines').get('r-1')?.title, '스트레칭');
    expect(Hive.box<Routine>('routines').get('r-1')?.activeDays, [1, 3, 5]);
    final restoredTask =
        Hive.box<AdditionalTask>('additionalTasks').get('t-1')!;
    expect(restoredTask.subtasks, ['우유', '계란']);
    expect(restoredTask.subtaskCompletions, [true, false]);
    expect(
      Hive.box<DailyRecord>('dailyRecords')
          .get('2026-03-17')
          ?.routineCompletions,
      {'r-1': true},
    );
    expect(Hive.box('appSettings').get('notificationEnabled'), false);
    expect(Hive.box('appSettings').get('themeMode'), 'dark');
  });

  test('지원하지 않는 버전은 에러', () async {
    final service = BackupService();
    expect(
      () => service.importFromJson('{"version": 99, "data": {}}'),
      throwsStateError,
    );
  });
}
