import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ptodolist/features/auth/providers/auth_providers.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';
import 'package:ptodolist/features/profile/providers/profile_providers.dart';

class ProfileEditView extends ConsumerStatefulWidget {
  /// true 면 첫 가입 — 닫기 버튼 막고 저장 후 자동 닫힘.
  final bool isFirstTime;

  const ProfileEditView({super.key, this.isFirstTime = false});

  @override
  ConsumerState<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends ConsumerState<ProfileEditView> {
  late final TextEditingController _nicknameController;
  PublicMode _publicMode = PublicMode.friends;
  bool _busy = false;
  String? _error;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _seedFrom(User user, UserProfile? profile) {
    if (_initialized) return;
    _initialized = true;
    _nicknameController.text = profile?.nickname ?? user.displayName ?? '';
    _publicMode = profile?.publicMode ?? PublicMode.friends;
  }

  Future<void> _save() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.length < 2 || nickname.length > 16) {
      setState(() => _error = '닉네임은 2~16자 사이로 입력하세요');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('로그인이 필요합니다');
      final existing = await ref.read(userProfileRepoProvider).get(user.uid);
      final now = DateTime.now();
      final profile = UserProfile(
        uid: user.uid,
        nickname: nickname,
        friendCode: existing?.friendCode ?? '', // 비어있으면 repo 가 자동 발급
        publicMode: _publicMode,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );
      await ref.read(userProfileRepoProvider).upsert(profile);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _error = '저장 실패: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;
    final profileAsync = ref.watch(myProfileProvider);

    if (user != null) {
      profileAsync.whenData((profile) => _seedFrom(user, profile));
    }

    return PopScope(
      canPop: !widget.isFirstTime,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isFirstTime ? '프로필 설정' : '프로필 편집'),
          automaticallyImplyLeading: !widget.isFirstTime,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.isFirstTime) ...[
                Text(
                  '환영해요!',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '닉네임을 정하면 친구 코드가 발급되고, 친구만 내 데이터를 볼 수 있어요.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text('닉네임', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _nicknameController,
                maxLength: 16,
                decoration: const InputDecoration(
                  hintText: '2~16자',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('공개 범위', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ...PublicMode.values.map((mode) => RadioListTile<PublicMode>(
                    value: mode,
                    groupValue: _publicMode,
                    onChanged: (v) =>
                        setState(() => _publicMode = v ?? _publicMode),
                    title: Text(mode.label),
                    subtitle: Text(
                      mode.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
