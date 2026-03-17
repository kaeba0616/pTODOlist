import 'package:hive/hive.dart';

class AppSettings {
  final bool notificationEnabled;
  final String notificationTime;
  final int retentionMonths;
  final String themeMode;

  const AppSettings({
    this.notificationEnabled = true,
    this.notificationTime = '23:00',
    this.retentionMonths = 6,
    this.themeMode = 'system',
  });
}

class SettingsRepository {
  final bool useMock;
  final Box? _box;

  SettingsRepository({this.useMock = false, Box? box}) : _box = box;

  AppSettings getSettings() {
    if (useMock) {
      return const AppSettings();
    }

    final box = _box!;
    return AppSettings(
      notificationEnabled: box.get('notificationEnabled', defaultValue: true),
      notificationTime: box.get('notificationTime', defaultValue: '23:00'),
      retentionMonths: box.get('retentionMonths', defaultValue: 6),
      themeMode: box.get('themeMode', defaultValue: 'system'),
    );
  }

  Future<void> updateNotificationEnabled(bool value) async {
    if (useMock) return;
    await _box!.put('notificationEnabled', value);
  }

  Future<void> updateNotificationTime(String value) async {
    if (useMock) return;
    await _box!.put('notificationTime', value);
  }

  Future<void> updateRetentionMonths(int value) async {
    if (useMock) return;
    await _box!.put('retentionMonths', value);
  }

  Future<void> updateThemeMode(String value) async {
    if (useMock) return;
    await _box!.put('themeMode', value);
  }
}
