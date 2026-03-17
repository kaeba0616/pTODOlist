import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ptodolist/features/settings/repos/settings_repo.dart';

class SettingsView extends StatefulWidget {
  final SettingsRepository? settingsRepo;

  const SettingsView({super.key, this.settingsRepo});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late bool _notificationEnabled;

  @override
  void initState() {
    super.initState();
    _notificationEnabled = widget.settingsRepo?.getSettings().notificationEnabled ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('카테고리 관리'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/categories'),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('11시 알림'),
            subtitle: const Text('미완료 항목이 있을 때만 알림'),
            value: _notificationEnabled,
            onChanged: (value) {
              setState(() => _notificationEnabled = value);
              widget.settingsRepo?.updateNotificationEnabled(value);
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
