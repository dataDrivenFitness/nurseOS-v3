import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  late final ProviderSubscription<AsyncValue<UserModel?>> _sub;

  AuthRefreshNotifier(Ref ref) {
    _sub = ref.listen<AsyncValue<UserModel?>>(
      authControllerProvider,
      (prev, next) {
        // 🛑 Prevent GoRouter refresh if user is still loading or errored
        if (next.isLoading || next.hasError) return;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

/// ✅ Riverpod provider to expose the notifier
final authRefreshNotifierProvider = Provider<AuthRefreshNotifier>((ref) {
  final notifier = AuthRefreshNotifier(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
