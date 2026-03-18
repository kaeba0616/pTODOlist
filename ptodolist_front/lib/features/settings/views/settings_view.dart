import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ptodolist/features/settings/repos/settings_repo.dart';

class SettingsView extends StatefulWidget {
  final SettingsRepository? settingsRepo;
  final ValueChanged<ThemeMode>? onThemeChanged;

  const SettingsView({super.key, this.settingsRepo, this.onThemeChanged});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late bool _notificationEnabled;
  late String _notificationTime;
  late int _retentionMonths;
  late String _themeMode;

  @override
  void initState() {
    super.initState();
    final settings = widget.settingsRepo?.getSettings() ?? const AppSettings();
    _notificationEnabled = settings.notificationEnabled;
    _notificationTime = settings.notificationTime;
    _retentionMonths = settings.retentionMonths;
    _themeMode = settings.themeMode;
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _displayTime(String time) {
    final t = _parseTime(time);
    final period = t.hour < 12 ? '오전' : '오후';
    final displayHour = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    return '$period $displayHour:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickNotificationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(_notificationTime),
    );
    if (picked != null) {
      final timeStr = _formatTime(picked);
      setState(() => _notificationTime = timeStr);
      widget.settingsRepo?.updateNotificationTime(timeStr);
    }
  }

  String _retentionLabel(int months) {
    if (months <= 0) return '무제한';
    if (months == 3) return '3개월';
    if (months == 6) return '6개월';
    if (months == 12) return '1년';
    return '$months개월';
  }

  String _themeLabel(String mode) {
    switch (mode) {
      case 'light':
        return '라이트';
      case 'dark':
        return '다크';
      default:
        return '시스템 설정';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          // 카테고리 관리
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('카테고리 관리'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/categories'),
          ),
          const Divider(height: 1),

          // 알림
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('알림'),
            subtitle: const Text('미완료 항목이 있을 때만 알림'),
            value: _notificationEnabled,
            onChanged: (value) {
              setState(() => _notificationEnabled = value);
              widget.settingsRepo?.updateNotificationEnabled(value);
            },
          ),
          if (_notificationEnabled)
            ListTile(
              leading: const SizedBox(width: 24),
              title: const Text('알림 시간'),
              trailing: TextButton(
                onPressed: _pickNotificationTime,
                child: Text(_displayTime(_notificationTime)),
              ),
            ),
          const Divider(height: 1),

          // 데이터 보관 기간
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('데이터 보관 기간'),
            trailing: DropdownButton<int>(
              value: _retentionMonths,
              underline: const SizedBox(),
              items: [3, 6, 12, 0].map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(_retentionLabel(m)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _retentionMonths = value);
                  widget.settingsRepo?.updateRetentionMonths(value);
                }
              },
            ),
          ),
          const Divider(height: 1),

          // 테마
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('테마'),
            trailing: DropdownButton<String>(
              value: _themeMode,
              underline: const SizedBox(),
              items: ['system', 'light', 'dark'].map((m) {
                return DropdownMenuItem(value: m, child: Text(_themeLabel(m)));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _themeMode = value);
                  widget.settingsRepo?.updateThemeMode(value);
                  widget.onThemeChanged?.call(
                    value == 'light'
                        ? ThemeMode.light
                        : value == 'dark'
                        ? ThemeMode.dark
                        : ThemeMode.system,
                  );
                }
              },
            ),
          ),
          const Divider(height: 1),

          // 앱 정보
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '정보',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('앱 버전'),
            trailing: Text('v1.0.0', style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}
