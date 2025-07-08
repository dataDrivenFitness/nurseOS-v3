# 🏛️ NurseOS Architecture v2

This document outlines the modular, testable, HIPAA-compliant architecture for the NurseOS app. All implementation must follow these patterns for consistency and maintainability.

---

## 📁 Folder Structure

```
lib/
├── core/       # Env, themes, typography, constants
├── features/   # One folder per feature (e.g., auth, profile, vitals)
├── shared/     # Shared UI widgets, utils, design tokens
```

---

## 🔄 State Management

- Uses **Riverpod v2** with `AsyncNotifier` and `Notifier`
- All business logic isolated in Notifier classes
- No direct Firebase access in widgets

### Provider Responsibilities

| Provider                      | Purpose                            |
|-------------------------------|------------------------------------|
| `authControllerProvider`      | Auth session + login/logout only   |
| `userProfileProvider`         | Profile info (name, avatar, role)  |
| `fontScaleControllerProvider` | App-wide text scaling toggle       |
| `AbstractXpRepository`        | Gamification XP badge logic        |

---

## 🧩 Feature Modules

Each feature lives in `lib/features/{name}/` and includes:

| Folder        | Role                                              |
|---------------|---------------------------------------------------|
| `models/`     | `freezed` models with Firestore converters        |
| `repository/` | Abstract interface + mock/live impl               |
| `controllers/`| Riverpod Notifier logic                           |
| `screens/`    | Entry point screens for the feature               |
| `widgets/`    | Feature-specific reusable components              |

---

## 💾 Firestore Strategy

- All models use `.withConverter<T>()`
- No `.data()` or `.map()` in widgets or controllers
- Required metadata fields:
  - `createdAt`, `updatedAt`
  - `createdBy`, `modifiedBy`

---

## ✨ UI System

- Typography scales via `MediaQuery.textScalerOf(context)`  
- App-wide override via `fontScaleControllerProvider`
- Animations from `core/theme/animation_tokens.dart`
- AppShell and route transitions defined via `GoRouter`

---

## 🧪 Testing Standards

Every feature must include:

| Type     | Required? | Description                                  |
|----------|-----------|----------------------------------------------|
| Unit     | ✅         | All controller and repo logic                |
| Widget   | ✅         | Screen flows and edge cases                  |
| Golden   | ✅         | Visuals including animated and default state |
| Scaling  | ✅         | All `Text()` honors text scale factor        |

---

## 🛡 HIPAA Compliance Requirements

- No PHI in widget tree or GPT prompts
- Firestore writes validated via backend rules
- PHI stored only in secure collections
- `guardFirebaseInitialization()` used at app boot

---

## 🧠 Gamification Support

- XP stored in `users/{uid}/xp` or `leaderboards/`
- Use `AbstractXpRepository` for all grants
- No XP for retries or automation
- Leaderboard is admin-only (no mobile view)

---

## 🧪 Mock Mode & Testability

- Controlled via `AppEnv.isMock`
- All repositories must support mock logic
- Golden tests use `FakeFirebase` when mock enabled

---

## 🔄 GoRouter + Auth Refresh Handling

NurseOS uses a custom `AuthRefreshNotifier` to ensure route evaluation triggers correctly on session change.

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

In `router.dart`:

```dart
refreshListenable: ref.watch(authRefreshNotifierProvider),
```

---

## 🧭 Font Scaling Integration

### Provider
```dart
final fontScaleControllerProvider =
    NotifierProvider<FontScaleController, double>(FontScaleController.new);
```

### Usage in App Root
```dart
final fontScale = ref.watch(fontScaleControllerProvider);
MediaQuery(
  data: MediaQuery.of(context).copyWith(textScaleFactor: fontScale),
  child: ...
)
```

Golden tests must override this provider and use a high scale value (e.g., `1.5`) to verify layout stability.

---

## 📤 Data Transfer

See [Document Transfer Protocol](doc_transfer_protocol.md) for secure patient data export guidelines.
