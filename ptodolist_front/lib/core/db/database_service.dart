import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {
  DatabaseService._();

  static Future<void> init() async {
    await Hive.initFlutter();

    // AppSettings 박스 열기
    await Hive.openBox('appSettings');
  }

  static Box getAppSettingsBox() {
    return Hive.box('appSettings');
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
