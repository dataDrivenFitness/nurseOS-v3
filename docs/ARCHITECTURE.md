
# NurseOS Architecture Overview

## 🛡️ GoRouter + Riverpod Auth Integration

### 🔄 Auth-Driven Route Refresh

To ensure that GoRouter reevaluates routes in response to changes in authentication state, we implement a custom `AuthRefreshNotifier`.

### 📦 Why Not `GoRouterRefreshStream`?

While `GoRouterRefreshStream` is included in GoRouter v6+, its symbol is not always reliably exposed across all IDEs and environments. We instead use a `ChangeNotifier` pattern that is:

- Fully compliant with Flutter's widget lifecycle
- Compatible with Riverpod’s `ProviderSubscription`
- Safe for production with correct disposal handling

### 🧱 Structure

**File:** `lib/features/auth/state/auth_refresh_notifier.dart`

```dart
class AuthRefreshNotifier extends ChangeNotifier {
  late final ProviderSubscription<AsyncValue<UserModel?>> _sub;

  AuthRefreshNotifier(Ref ref) {
    _sub = ref.listen<AsyncValue<UserModel?>>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
```

### 📡 Connected in `appRouterProvider`

```dart
refreshListenable: ref.watch(authRefreshNotifierProvider),
```

This approach ensures that route redirects fire correctly upon sign-in, sign-out, or user restoration events, without depending on unstable internal exports.
