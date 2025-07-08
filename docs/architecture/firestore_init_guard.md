
# Firestore Initialization Guard – NurseOS v2

> Ensures that Firebase is initialized exactly once before use, and blocks app logic if initialization fails.

---

## ✅ Purpose

Prevents runtime errors from uninitialized Firebase services. Enforces a single, async-safe guard for app startup.

---

## 🛠️ Usage

```dart
await guardFirebaseInitialization();
```

Call this before any `ProviderScope`, `runApp()`, or Firestore access.

---

## 🔐 Guard Logic

```dart
Future<void> guardFirebaseInitialization() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e, st) {
    // Optional: log to Crashlytics or print
    throw FirebaseInitException('Firebase failed to initialize', e, st);
  }
}
```

---

## 🔒 FirebaseInitException

```dart
class FirebaseInitException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  FirebaseInitException(this.message, [this.cause, this.stackTrace]);

  @override
  String toString() => 'FirebaseInitException: $message\n$cause\n$stackTrace';
}
```

---

## 🔁 Retry Pattern (Optional)

Wrap the call in a retry loop if needed for flaky devices:

```dart
await retry(
  () => guardFirebaseInitialization(),
  retryIf: (e) => e is FirebaseInitException,
  maxAttempts: 3,
);
```

---

## 🧪 Testing Notes

- Unit test failure paths with simulated bad config
- Wrap with `runZonedGuarded` in main entry point

---

## 🚫 Anti-Patterns

- ❌ Don’t call `Firebase.initializeApp()` more than once
- ❌ Don’t initialize Firebase in widget build methods

---

## 🧩 Location

File lives at:

```
lib/core/firebase/guard_firebase.dart
```

---

## ✅ Required By

- `main.dart`
- `test/bootstrap.dart`
- All features depending on Firestore, Auth, or Functions

---
