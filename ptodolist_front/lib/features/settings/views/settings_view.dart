import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ptodolist/core/db/backup_service.dart';
import 'package:ptodolist/core/theme/app_theme.dart';
import 'package:ptodolist/core/utils/storage_info.dart';
import 'package:ptodolist/features/auth/providers/auth_providers.dart';
import 'package:ptodolist/features/auth/views/login_view.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';
import 'package:ptodolist/features/profile/providers/profile_providers.dart';
import 'package:ptodolist/features/profile/views/profile_edit_view.dart';
import 'package:ptodolist/features/settings/repos/settings_repo.dart';
import 'package:share_plus/share_plus.dart';

class SettingsView extends ConsumerStatefulWidget {
  final SettingsRepository? settingsRepo;
  final ValueChanged<ThemeMode>? onThemeChanged;

  const SettingsView({super.key, this.settingsRepo, this.onThemeChanged});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  late bool _notificationEnabled;
  late String _notificationTime;
  late int _retentionMonths;
  late String _themeMode;
  int? _storageBytes;

  @override
  void initState() {
    super.initState();
    final settings = widget.settingsRepo?.getSettings() ?? const AppSettings();
    _notificationEnabled = settings.notificationEnabled;
    _notificationTime = settings.notificationTime;
    _retentionMonths = settings.retentionMonths;
    _themeMode = settings.themeMode;
    _loadStorageSize();
  }

  Future<void> _loadStorageSize() async {
    final bytes = await StorageInfo.getHiveBoxesSizeBytes();
    if (!mounted) return;
    setState(() => _storageBytes = bytes);
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
              color: theme.colorScheme.primary),
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

          // Account section
          _buildAccountSection(theme, isDark),
          const SizedBox(height: 24),

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

          // Backup section
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'BACKUP',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
          ),
          _buildSettingItem(
            theme: theme,
            isDark: isDark,
            icon: Icons.upload_outlined,
            title: '데이터 내보내기',
            subtitle: 'JSON 파일로 백업 공유',
            onTap: _exportBackup,
          ),
          const SizedBox(height: 8),
          _buildSettingItem(
            theme: theme,
            isDark: isDark,
            icon: Icons.download_outlined,
            title: '데이터 가져오기',
            subtitle: '백업 파일에서 복원 (기존 데이터 대체)',
            onTap: _importBackup,
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

  Widget _buildAccountSection(ThemeData theme, bool isDark) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final profile = ref.watch(myProfileProvider).valueOrNull;
    final cardColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surface;

    final title = user == null
        ? '로그인 안 됨'
        : (profile?.nickname.isNotEmpty == true
            ? profile!.nickname
            : (user.displayName ?? '사용자'));

    final subtitle = user == null
        ? '다른 사람의 루틴을 보려면 로그인 필요'
        : (profile == null
            ? '프로필을 설정해주세요'
            : (profile.friendCode.isNotEmpty
                ? '코드 ${profile.friendCode} · ${profile.publicMode.label}'
                : '${profile.publicMode.label} · ${user.email ?? '익명'}'));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? null
            : Border.all(
                color: AppTheme.outlineVariant.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(
            user == null ? Icons.person_outline : Icons.account_circle,
            size: 32,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (user == null)
            FilledButton.tonal(
              onPressed: _openLogin,
              child: const Text('로그인'),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'edit') _openProfileEdit();
                if (v == 'logout') _signOut();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('프로필 편집')),
                PopupMenuItem(value: 'logout', child: Text('로그아웃')),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _openProfileEdit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileEditView()),
    );
  }

  Future<void> _openLogin() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃해도 로컬 데이터는 그대로 유지돼요.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('로그아웃')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(authServiceProvider).signOut();
  }

  Widget _buildPrivacyCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
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
                      color: theme.colorScheme.onPrimaryContainer,
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
                  color: theme.colorScheme.onPrimaryContainer
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
    final cardColor = (theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest);
    final iconBgDefault = theme.colorScheme.surfaceContainerHighest;

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
    final cardColor = isDark ? theme.colorScheme.surface : AppTheme.surfaceContainerLow;
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
                Builder(
                  builder: (_) {
                    final (num, unit) = _storageBytes == null
                        ? ('--', 'KB')
                        : StorageInfo.formatSplit(_storageBytes!);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(num,
                            style: GoogleFonts.manrope(
                                fontSize: 24, fontWeight: FontWeight.w300)),
                        const SizedBox(width: 2),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(unit,
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  '로컬 DB 사용량',
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

  Future<void> _exportBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await BackupService().writeExportToFile();
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'pTODOlist 백업',
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('내보내기 실패: $e')),
      );
    }
  }

  Future<void> _importBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('데이터 가져오기'),
        content: const Text('백업 파일을 불러오면 기존 데이터가 모두 대체됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('가져오기'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      final file = File(result.files.single.path!);
      final json = await file.readAsString();
      await BackupService().importFromJson(json);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('가져오기 완료. 앱을 재시작해주세요.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('가져오기 실패: $e')),
      );
    }
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
