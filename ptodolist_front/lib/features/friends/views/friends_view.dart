import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ptodolist/core/utils/friend_code_generator.dart';
import 'package:ptodolist/features/auth/providers/auth_providers.dart';
import 'package:ptodolist/features/friends/models/friendship.dart';
import 'package:ptodolist/features/friends/providers/friends_providers.dart';
import 'package:ptodolist/features/friends/views/friend_detail_view.dart';
import 'package:ptodolist/features/profile/providers/profile_providers.dart';

class FriendsView extends ConsumerStatefulWidget {
  const FriendsView({super.key});

  @override
  ConsumerState<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends ConsumerState<FriendsView> {
  final _codeController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final raw = _codeController.text;
    if (!FriendCodeGenerator.isValid(raw)) {
      _snack('유효한 8자 코드가 아니에요');
      return;
    }
    final myProfile = ref.read(myProfileProvider).valueOrNull;
    if (myProfile == null) {
      _snack('프로필이 아직 준비 안 됐어요');
      return;
    }
    setState(() => _sending = true);
    try {
      final targetUid = await ref
          .read(userProfileRepoProvider)
          .findUidByFriendCode(raw);
      if (targetUid == null) {
        _snack('해당 코드의 사용자를 찾을 수 없어요');
        return;
      }
      await ref.read(friendsRepoProvider).sendRequest(
            toUid: targetUid,
            fromProfile: myProfile,
          );
      _codeController.clear();
      _snack('요청을 보냈어요');
    } on StateError catch (e) {
      if (e.message == 'already-friends') {
        _snack('이미 친구예요');
      } else {
        _snack('요청 실패: ${e.message}');
      }
    } on ArgumentError catch (e) {
      _snack(e.message?.toString() ?? '요청 불가');
    } catch (e) {
      _snack('요청 실패: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
  }

  Future<void> _accept(String fromUid) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    try {
      await ref.read(friendsRepoProvider).accept(
            myUid: user.uid,
            fromUid: fromUid,
          );
      _snack('친구가 됐어요');
    } catch (e) {
      _snack('수락 실패: $e');
    }
  }

  Future<void> _decline(String fromUid) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    try {
      await ref.read(friendsRepoProvider).decline(
            myUid: user.uid,
            fromUid: fromUid,
          );
    } catch (e) {
      _snack('거절 실패: $e');
    }
  }

  Future<void> _removeFriend(String otherUid) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('친구 끊기'),
        content: const Text('정말 친구 관계를 끊을까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('끊기')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(friendsRepoProvider).removeFriend(
            myUid: user.uid,
            otherUid: otherUid,
          );
      _snack('친구를 끊었어요');
    } catch (e) {
      _snack('실패: $e');
    }
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    _snack('코드 복사됨');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;
    final profile = ref.watch(myProfileProvider).valueOrNull;
    final incoming = ref.watch(incomingRequestsProvider).valueOrNull ?? [];
    final friends = ref.watch(myFriendshipsProvider).valueOrNull ?? [];

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('친구')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('친구 기능을 쓰려면 먼저 로그인하세요.'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('친구')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMyCodeCard(theme, profile?.friendCode ?? ''),
            const SizedBox(height: 24),
            _buildAddFriendCard(theme),
            if (incoming.isNotEmpty) ...[
              const SizedBox(height: 24),
              _sectionLabel(theme, '받은 요청 (${incoming.length})'),
              const SizedBox(height: 8),
              ...incoming.map((req) => _buildRequestTile(theme, req)),
            ],
            const SizedBox(height: 24),
            _sectionLabel(theme, '내 친구 (${friends.length})'),
            const SizedBox(height: 8),
            if (friends.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '아직 친구가 없어요. 친구 코드를 공유해 추가해보세요.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...friends.map(
                  (f) => _buildFriendTile(theme, user.uid, f)),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.5,
        ),
      );

  Widget _buildMyCodeCard(ThemeData theme, String code) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(theme, 'MY FRIEND CODE'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  code.isEmpty ? '발급 중…' : code,
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              if (code.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyCode(code),
                  tooltip: '복사',
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '이 코드를 친구에게 알려주면 친구가 너를 추가할 수 있어요.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFriendCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(theme, '친구 추가'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: '친구의 코드 입력 (예: KX7B-29M3)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _sending ? null : _sendRequest,
                child: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('요청'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTile(ThemeData theme, FriendRequest req) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.person_add_outlined),
        title: Text(req.fromNickname.isEmpty ? '알 수 없음' : req.fromNickname),
        subtitle: Text('코드 ${req.fromCode}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => _decline(req.fromUid),
              child: const Text('거절'),
            ),
            FilledButton(
              onPressed: () => _accept(req.fromUid),
              child: const Text('수락'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendTile(
      ThemeData theme, String myUid, Friendship friendship) {
    final otherUid = friendship.otherMember(myUid);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.account_circle),
        title: FutureBuilder(
          future: ref.read(userProfileRepoProvider).get(otherUid),
          builder: (ctx, snap) {
            final p = snap.data;
            return Text(p?.nickname.isNotEmpty == true ? p!.nickname : '친구');
          },
        ),
        subtitle: const Text('탭해서 오늘 진행률 보기',
            style: TextStyle(fontSize: 11)),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FriendDetailView(friendUid: otherUid),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (v) {
            if (v == 'remove') _removeFriend(otherUid);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'remove', child: Text('친구 끊기')),
          ],
        ),
      ),
    );
  }
}
