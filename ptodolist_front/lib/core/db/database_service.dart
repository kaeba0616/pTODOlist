import 'package:hive_flutter/hive_flutter.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/models/category_adapter.dart';
import 'package:ptodolist/features/category/mocks/category_mock.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/routine/models/routine_adapter.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';
import 'package:ptodolist/features/task/models/additional_task_adapter.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/home/models/daily_record_adapter.dart';

class DatabaseService {
  DatabaseService._();

  static Future<void> init() async {
    await Hive.initFlutter();

    // TypeAdapters 등록
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(RoutineAdapter());
    Hive.registerAdapter(AdditionalTaskAdapter());
    Hive.registerAdapter(DailyRecordAdapter());

    // 박스 열기
    await Hive.openBox('appSettings');
    await Hive.openBox<Category>('categories');
    await Hive.openBox<Routine>('routines');
    await Hive.openBox<AdditionalTask>('additionalTasks');
    await Hive.openBox<DailyRecord>('dailyRecords');

    // 첫 실행 시 기본 카테고리 시드
    await _seedDefaultCategories();
  }

  static Future<void> _seedDefaultCategories() async {
    final box = Hive.box<Category>('categories');
    if (box.isEmpty) {
      for (final category in defaultCategories) {
        await box.put(category.id, category);
      }
    }
  }

  static Box getAppSettingsBox() {
    return Hive.box('appSettings');
  }

  static Box<Category> getCategoriesBox() {
    return Hive.box<Category>('categories');
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
