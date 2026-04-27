import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ptodolist/features/auth/providers/auth_providers.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  bool _busy = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '로그인 실패: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(Icons.people_outline,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              '다른 사람의 루틴 보기',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '로그인하면 오늘 다른 사람들의\n루틴 달성률을 확인할 수 있어요',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _busy ? null : _signInWithGoogle,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login),
              label: Text(_busy ? '로그인 중...' : 'Google 로 계속하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              '* 로그인 없이도 모든 로컬 기능을 사용할 수 있어요',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
