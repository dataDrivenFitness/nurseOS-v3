# 🧪 NurseOS Router + Auth Testing Guidelines

_Last updated: 2025-06-23_

This document standardizes how we test GoRouter + Riverpod integration with authenticated roles in NurseOS v3. It avoids brittle test setups and breaks the circular failure loop we've experienced.

---

## ✅ Mocking AuthController for Tests

Use a **`FakeAuthController` subclass** of `AsyncNotifier<UserModel?>`. Never override with `.overrideWith` directly in tests.

### Standard Mock Class

```dart
class FakeAuthController extends AsyncNotifier<UserModel?> {
  final UserModel mockUser;
  FakeAuthController(this.mockUser);

  @override
  FutureOr<UserModel?> build() => mockUser;
}
```

### In test override:

```dart
ProviderScope(
  overrides: [
    authControllerProvider.overrideWith(() => FakeAuthController(mockUser)),
  ],
  child: Consumer(
    builder: (context, ref, _) {
      final router = ref.watch(appRouterProvider);
      return MaterialApp.router(routerConfig: router);
    },
  ),
);
```

---

## 🔑 Keys for Widget Expectations

These keys must be present to verify routing worked:

| Screen              | Key                    |
|---------------------|-------------------------|
| App Shell           | `ValueKey('app-shell')` |
| Patients List       | `Key('assignedPatientsTitle')` |
| Login Screen        | `Key('login-screen')`   |

---

## 🔁 GoRouter Test Setup Tips

- Always call `await tester.pumpAndSettle()` after `pumpWidget`.
- Set `initialLocation` inside the `GoRouter` definition if needed to bypass default redirects.
- Don’t check for `find.text()` first—check for `find.byKey()` to confirm route was loaded.

---

## ⚠️ Common Pitfalls

| Symptom | Cause | Fix |
|--------|-------|------|
| `app-shell` not found | `FakeAuthController` not wired | Use `.overrideWith` not `.overrideWithValue` |
| Redirection stuck | `AsyncValue.loading` state not handled | Use fully initialized `AsyncData<UserModel>` |
| `routerConfig` not triggering screen | `Consumer` not wrapping `MaterialApp.router` | Always embed router inside consumer |

---

## ⚙️ To Regenerate Routing Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

Files:
- `lib/core/router/router_notifier.g.dart`
- `lib/core/router/app_router.g.dart`

---

## ✅ Test Template

```dart
testWidgets('renders Assigned Patients for nurse', (tester) async {
  final mockUser = UserModel(...);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(() => FakeAuthController(mockUser)),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final router = ref.watch(appRouterProvider);
          return MaterialApp.router(routerConfig: router);
        },
      ),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.byKey(const ValueKey('app-shell')), findsOneWidget);
  expect(find.byKey(const Key('assignedPatientsTitle')), findsOneWidget);
});
```

---

## 🧪 Golden Test Reminder

If screen routing or microanimation is part of the test flow:
- Capture pre and post `pumpAndSettle`
- Check XP side effects via badge expectations if gamification involved
