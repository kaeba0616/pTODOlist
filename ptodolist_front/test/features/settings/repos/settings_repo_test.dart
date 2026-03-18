import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/settings/repos/settings_repo.dart';

void main() {
  group('SettingsRepository (Mock)', () {
    late SettingsRepository repo;

    setUp(() {
      repo = SettingsRepository(useMock: true);
    });

    test('기본 설정값을 반환한다', () {
      final settings = repo.getSettings();

      expect(settings.notificationEnabled, true);
      expect(settings.notificationTime, '23:00');
      expect(settings.retentionMonths, 6);
      expect(settings.themeMode, 'system');
    });
  });

  group('AppSettings', () {
    test('기본값으로 생성된다', () {
      const settings = AppSettings();

      expect(settings.notificationEnabled, true);
      expect(settings.notificationTime, '23:00');
      expect(settings.retentionMonths, 6);
      expect(settings.themeMode, 'system');
    });

    test('커스텀 값으로 생성된다', () {
      const settings = AppSettings(
        notificationEnabled: false,
        notificationTime: '22:00',
        retentionMonths: 12,
        themeMode: 'dark',
      );

      expect(settings.notificationEnabled, false);
      expect(settings.notificationTime, '22:00');
      expect(settings.retentionMonths, 12);
      expect(settings.themeMode, 'dark');
    });

    test('notificationTime 파싱: TimeOfDay로 변환 가능하다', () {
      const settings = AppSettings(notificationTime: '21:30');
      final parts = settings.notificationTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      expect(hour, 21);
      expect(minute, 30);
    });
  });
}
