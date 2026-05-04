import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/features/profile/providers/profile_providers.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/social/models/daily_share.dart';
import 'package:ptodolist/features/social/providers/social_providers.dart';

/// 친구 한 명의 오늘 (혹은 지정 날짜) 진행률 카드 + 등록한 전체 루틴 리스트.
class FriendDetailView extends ConsumerWidget {
  final String friendUid;
  final String? date;

  const FriendDetailView({super.key, required this.friendUid, this.date});

  String get _date =>
      date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<List<Routine>> _fetchFriendRoutines() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .collection('routines')
          .get();
      return snap.docs
          .map((d) => Routine.fromMap({...d.data(), 'id': d.id}))
          .where((r) => !r.isDeleted)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      debugPrint('fetchFriendRoutines failed: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shareStream =
        ref.watch(dailyShareRepoProvider).watchUserDate(friendUid, _date);
    final profileFuture =
        ref.read(userProfileRepoProvider).get(friendUid);
    final routinesFuture = _fetchFriendRoutines();

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: profileFuture,
          builder: (ctx, snap) {
            final p = snap.data;
            return Text(p?.nickname.isNotEmpty == true ? p!.nickname : '친구');
          },
        ),
      ),
      body: StreamBuilder<DailyShare?>(
        stream: shareStream,
        builder: (ctx, snap) {
          final share = snap.data;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildProgressCard(theme, share),
              const SizedBox(height: 24),
              _sectionLabel(theme, '등록한 루틴'),
              const SizedBox(height: 8),
              FutureBuilder<List<Routine>>(
                future: routinesFuture,
                builder: (ctx, rSnap) {
                  if (rSnap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final routines = rSnap.data ?? [];
                  if (routines.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '친구가 등록한 루틴이 없어요',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  // 루틴별 오늘 완료 상태 매핑 — share.routines 의 name 으로 join
                  final doneByName = <String, bool>{
                    for (final r in (share?.routines ?? const []))
                      r.name: r.done,
                  };
                  return Column(
                    children: routines
                        .map((r) => _routineTile(
                              theme,
                              r,
                              doneByName[r.title] ?? false,
                            ))
                        .toList(),
                  );
                },
              ),
              if (share != null) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '마지막 업데이트: ${DateFormat('M/d HH:mm').format(share.updatedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
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

  Widget _buildProgressCard(ThemeData theme, DailyShare? share) {
    final percent = share == null ? 0 : (share.rate * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _date,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percent',
                style: GoogleFonts.manrope(
                  fontSize: 56,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 4),
                child: Text('%',
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ),
              const Spacer(),
              if (share != null)
                Text(
                  '${share.completedCount}/${share.totalCount}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: share?.rate ?? 0,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _routineTile(ThemeData theme, Routine r, bool done) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          r.title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : null,
            color: done ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: r.activeDays.isEmpty
            ? null
            : Text(
                _activeDaysLabel(r.activeDays),
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }

  String _activeDaysLabel(List<int> days) {
    const names = ['월', '화', '수', '목', '금', '토', '일'];
    final sorted = List<int>.from(days)..sort();
    if (sorted.length == 7) return '매일';
    return sorted.map((d) => names[d - 1]).join(' ');
  }
}
