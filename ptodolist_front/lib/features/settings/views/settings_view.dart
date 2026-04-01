import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ptodolist/core/theme/app_theme.dart';
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
    final displayHour =
        t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calendar_today, size: 20,
              color: isDark ? const Color(0xFFB1F0CE) : AppTheme.brandAccent),
            const SizedBox(width: 8),
            Text('pTODOlist'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Title
          _buildTitle(theme),
          const SizedBox(height: 20),

          // Privacy card
          _buildPrivacyCard(theme, isDark),
          const SizedBox(height: 24),

          // Data & Routine section
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'DATA & ROUTINE',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
          ),

          // Settings items
          _buildSettingItem(
            theme: theme,
            isDark: isDark,
            icon: Icons.category_outlined,
            title: '카테고리 관리',
            subtitle: '루틴 카테고리 편집',
            onTap: () => context.go('/settings/categories'),
          ),
          const SizedBox(height: 8),
          _buildSettingItem(
            theme: theme,
            isDark: isDark,
            icon: Icons.notifications_active_outlined,
            title: '알림',
            subtitle: _notificationEnabled
                ? _displayTime(_notificationTime)
                : '알림 꺼짐',
            trailing: Switch(
              value: _notificationEnabled,
              onChanged: (value) {
                setState(() => _notificationEnabled = value);
                widget.settingsRepo?.updateNotificationEnabled(value);
              },
            ),
          ),
          if (_notificationEnabled) ...[
            const SizedBox(height: 8),
            _buildSettingItem(
              theme: theme,
              isDark: isDark,
              icon: Icons.access_time,
              title: '알림 시간',
              subtitle: _displayTime(_notificationTime),
              onTap: _pickNotificationTime,
            ),
          ],
          const SizedBox(height: 8),
          _buildSettingItem(
            theme: theme,
            isDark: isDark,
            icon: Icons.cleaning_services_outlined,
            title: '데이터 보관 기간',
            subtitle: _retentionLabel(_retentionMonths),
            onTap: () => _showRetentionPicker(theme),
          ),
          const SizedBox(height: 8),
          _buildSettingItem(
            theme: theme,
            isDark: isDark,
            icon: Icons.palette_outlined,
            title: '테마',
            subtitle: _themeLabel(_themeMode),
            onTap: () => _showThemePicker(theme),
          ),

          // Danger zone
          const SizedBox(height: 24),
          _buildSettingItem(
            theme: theme,
            isDark: isDark,
            icon: Icons.restart_alt,
            title: '앱 초기화',
            subtitle: '모든 데이터를 영구 삭제',
            isDestructive: true,
            onTap: () => _showResetConfirm(theme),
          ),

          // System stats
          const SizedBox(height: 32),
          _buildSystemStats(theme, isDark),

          // App version
          const SizedBox(height: 24),
          Center(
            child: Text(
              'pTODOlist v1.0.0',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WORKSPACE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '설정',
            style: GoogleFonts.manrope(
              fontSize: 36,
              fontWeight: FontWeight.w200,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF005050).withValues(alpha: 0.3)
            : AppTheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF005050).withValues(alpha: 0.2)
              : AppTheme.primaryContainer.withValues(alpha: 0.4),
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, size: 20,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '로컬 전용 프라이버시',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFB1F0CE)
                          : AppTheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '모든 데이터는 기기에서만 저장됩니다.\n클라우드 동기화 없이, 안전하게.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.5,
                  color: (isDark
                          ? const Color(0xFFB1F0CE)
                          : AppTheme.onPrimaryContainer)
                      .withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          Positioned(
            right: -8,
            bottom: -8,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final cardColor = isDark ? const Color(0xFF22252A) : AppTheme.surfaceContainerLowest;
    final iconBgDefault = isDark ? const Color(0xFF2E3238) : AppTheme.surfaceContainerHigh;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDestructive
                    ? AppTheme.errorContainer.withValues(alpha: 0.1)
                    : iconBgDefault,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive ? AppTheme.error : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDestructive
                          ? AppTheme.error
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDestructive
                          ? AppTheme.error.withValues(alpha: 0.7)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (!isDestructive)
              Icon(Icons.chevron_right, size: 20,
                  color: theme.colorScheme.outlineVariant)
            else
              Icon(Icons.warning_amber, size: 20,
                  color: AppTheme.error.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStats(ThemeData theme, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1A1C1E) : AppTheme.surfaceContainerLow;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? null
                  : Border.all(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STORAGE',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('12.4',
                        style: GoogleFonts.manrope(
                            fontSize: 24, fontWeight: FontWeight.w300)),
                    const SizedBox(width: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text('MB',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: LinearProgressIndicator(
                    value: 0.25,
                    minHeight: 4,
                    backgroundColor: AppTheme.surfaceContainerHighest,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? null
                  : Border.all(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THEME',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _themeLabel(_themeMode),
                  style: GoogleFonts.manrope(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '자동 전환',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRetentionPicker(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [3, 6, 12, 0].map((m) {
            return ListTile(
              title: Text(_retentionLabel(m)),
              trailing: _retentionMonths == m
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                setState(() => _retentionMonths = m);
                widget.settingsRepo?.updateRetentionMonths(m);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemePicker(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['system', 'light', 'dark'].map((m) {
            return ListTile(
              title: Text(_themeLabel(m)),
              trailing: _themeMode == m
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                setState(() => _themeMode = m);
                widget.settingsRepo?.updateThemeMode(m);
                widget.onThemeChanged?.call(
                  m == 'light'
                      ? ThemeMode.light
                      : m == 'dark'
                          ? ThemeMode.dark
                          : ThemeMode.system,
                );
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showResetConfirm(ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('앱 초기화'),
        content: const Text('모든 데이터가 영구적으로 삭제됩니다.\n정말 초기화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}
