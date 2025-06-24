import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';
import '../models/user_model.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  late final ProviderSubscription<AsyncValue<UserModel?>> _sub;

  AuthRefreshNotifier(Ref ref) {
    _sub = ref.listen<AsyncValue<UserModel?>>(
      authControllerProvider,
      (_, __) {
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
