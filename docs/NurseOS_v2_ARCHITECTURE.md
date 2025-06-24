# NurseOS v2 Architecture – Unified Blueprint

A lightweight, test-driven, HIPAA-safe Flutter rebuild of NurseOS using Clean Architecture, Riverpod, and Firestore-first modularity.

---

## 🧱 1. Layered Architecture

```
UI Widgets ─┬─ Riverpod Feature Notifiers ─┬─ Repositories ─┬─ Data Sources (Firebase / REST)
            │                            │                 └─ Abstracted Firestore
            │                            └─ Domain Models (Freezed)
            └─ Design System Components
```

---

## 📁 2. Folder Structure

```
lib/
  core/        ← env, theme, tokens, global logic
  features/    ← one per slice (e.g., patient, gamification, auth)
  shared/      ← widgets, design atoms
test/          ← unit, widget, golden tests
```

---

## ✍️ 3. Naming Conventions

| Item           | Convention                |
|----------------|---------------------------|
| Models         | `SomethingModel`          |
| Providers      | `somethingProvider`       |
| AsyncNotifiers | `SomethingController`     |
| Screens        | `SomethingScreen`         |

---

## 🔁 4. State Management

- Riverpod v2 (AsyncNotifier / Notifier only)
- All async logic wrapped with `AsyncValue.guard()` and `.when()`
- No `setState` in production widgets

---

## 🔌 5. Firestore & Data Layer

- Use `.withConverter<T>()` — no raw Maps
- Access Firestore only inside `FirebaseXRepository` files
- One aggregate root per collection (e.g., `patients/`, `users/`)

---

## 🔐 6. GoRouter + Auth Integration

- Uses `AuthRefreshNotifier` (ChangeNotifier) to listen to `authControllerProvider`
- Ensures `GoRouter` refreshes on sign in/out or restore
- Safer than `GoRouterRefreshStream`

```dart
class AuthRefreshNotifier extends ChangeNotifier {
  late final ProviderSubscription<AsyncValue<UserModel?>> _sub;
  AuthRefreshNotifier(Ref ref) {
    _sub = ref.listen<AsyncValue<UserModel?>>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
  @override void dispose() { _sub.close(); super.dispose(); }
}
```

---

## 🎨 7. Theming & Design System

- Dark theme first
- Use `AppColors`, `SpacingTokens`, `TextStyles`
- No literal `Colors.*`; only theme extensions
- Font scaling via `MediaQuery.textScalerOf(context)`

---

## 🧪 8. Testing Strategy

| Type       | Requirement            |
|------------|------------------------|
| Unit       | Every model/repo       |
| Widget     | Every screen interaction |
| Golden     | Reusable components    |
| Coverage   | ≥ 30% before release   |

---

## 🚀 9. CI/CD & Tooling

- GitHub Actions:
  - `flutter analyze`, `flutter test`, `dart format`
- Pre-commit: format + analyze
- Use `very_good_analysis` or equivalent

---

## 🛡️ 10. Drift Prevention Guardrails

- Every PR must modify or add a test
- No runtime `as` or type casts
- Architecture reviewed weekly
- Major changes go in `/docs/decisions/`

---
