import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptodolist/features/auth/providers/auth_providers.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';
import 'package:ptodolist/features/profile/repos/user_profile_repo.dart';

final userProfileRepoProvider =
    Provider<UserProfileRepository>((ref) => UserProfileRepository());

/// 현재 로그인한 사용자의 프로필 (로그아웃 시 null)
final myProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref.watch(userProfileRepoProvider).watch(user.uid);
});
