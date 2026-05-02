import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/features/profile/providers/profile_providers.dart';
import 'package:ptodolist/features/social/models/daily_share.dart';
import 'package:ptodolist/features/social/providers/social_providers.dart';

/// 친구 한 명의 오늘 (혹은 지정 날짜) dailyShare 를 카드 형태로.
class FriendDetailView extends ConsumerWidget {
  final String friendUid;
  final String? date;

  const FriendDetailView({super.key, required this.friendUid, this.date});

  String get _date =>
      date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shareStream =
        ref.watch(dailyShareRepoProvider).watchUserDate(friendUid, _date);
    final profileFuture =
        ref.read(userProfileRepoProvider).get(friendUid);

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
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final share = snap.data;
          if (share == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(
                      '$_date 의 기록이 없어요',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildContent(theme, share);
        },
      ),
    );
  }

  Widget _buildContent(ThemeData theme, DailyShare share) {
    final percent = (share.rate * 100).round();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
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
                  value: share.rate,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('루틴',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.5,
            )),
        const SizedBox(height: 8),
        if (share.routines.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('등록된 루틴이 없어요',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          )
        else
          ...share.routines.map((r) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    r.done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: r.done
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    r.name,
                    style: TextStyle(
                      decoration: r.done ? TextDecoration.lineThrough : null,
                      color: r.done
                          ? theme.colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                ),
              )),
        const SizedBox(height: 16),
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
    );
  }
}
