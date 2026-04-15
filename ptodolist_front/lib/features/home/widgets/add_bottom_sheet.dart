import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ptodolist/core/theme/app_theme.dart';

enum AddType { routine, task }

class AddBottomSheet extends StatelessWidget {
  const AddBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '무엇을 추가할까요?',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 20),
            // Routine option
            _buildOption(
              context: context,
              isDark: isDark,
              theme: theme,
              icon: Icons.repeat,
              iconBg: theme.colorScheme.primaryContainer,
              iconColor: theme.colorScheme.onPrimaryContainer,
              title: '루틴 추가',
              subtitle: '매일 반복하는 할 일',
              onTap: () => Navigator.pop(context, AddType.routine),
            ),
            const SizedBox(height: 8),
            // Task option
            _buildOption(
              context: context,
              isDark: isDark,
              theme: theme,
              icon: Icons.check_circle_outline,
              iconBg: theme.colorScheme.surfaceContainerHighest,
              iconColor: theme.colorScheme.onSurfaceVariant,
              title: '할 일 추가',
              subtitle: '오늘만 할 일',
              onTap: () => Navigator.pop(context, AddType.task),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required bool isDark,
    required ThemeData theme,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final cardBg = (theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: theme.colorScheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}
