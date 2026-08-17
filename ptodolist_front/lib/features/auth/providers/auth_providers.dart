import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptodolist/core/push/push_token_registry.dart';
import 'package:ptodolist/features/auth/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(pushTokens: pushTokenServiceInstance),
);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});
