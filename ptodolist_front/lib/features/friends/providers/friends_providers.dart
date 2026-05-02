import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptodolist/features/auth/providers/auth_providers.dart';
import 'package:ptodolist/features/friends/models/friendship.dart';
import 'package:ptodolist/features/friends/repos/friends_repo.dart';

final friendsRepoProvider = Provider<FriendsRepository>((ref) => FriendsRepository());

/// 받은 친구 요청 (로그인 필요).
final incomingRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(friendsRepoProvider).watchIncoming(user.uid);
});

/// 내 친구 목록.
final myFriendshipsProvider = StreamProvider<List<Friendship>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref.watch(friendsRepoProvider).watchMyFriendships(user.uid);
});
