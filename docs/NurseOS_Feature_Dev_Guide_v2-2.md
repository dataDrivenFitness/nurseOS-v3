# 🧠 NurseOS Feature Development Guide – v2.2

> Standards and lifecycle for building HIPAA-compliant, test-verified, gamified features in NurseOS.

---

## 📁 Feature Folder Structure

Each feature lives under:

```
lib/features/{feature_name}/
```

**Must include:**

- `controllers/` – Riverpod `Notifier` or `AsyncNotifier` logic
- `models/` – `freezed` data classes with Firestore `.withConverter()`
- `repository/` – `Abstract{Feature}Repository` + optional mock/live impls
- `screens/` – Top-level UI views (wrapped in `.when()`)
- `widgets/` – Reusable components specific to this feature

---

## 🔁 Development Lifecycle

1. **Design UX**
   - Reference `nurseos_ux_recommendations_v2.md`
2. **Create Feature Directory**
   - Use `flutter create .` idioms
3. **Define Freezed Models**
   - Include: `createdAt`, `updatedAt`, `createdBy`, `modifiedBy`
4. **Abstract Repository**
   - Interface: `Abstract{Feature}Repository`
5. **Notifier Layer**
   - Must use `Notifier` or `AsyncNotifier`
   - All state must be testable
6. **Build Screens**
   - Wrap all async logic in `.when()`
   - Animate using `animation_tokens.dart`
7. **Write Tests**
   - Unit, widget, golden, scaling
8. **Wire Gamification (if applicable)**
   - Use `grantXp()` in `AbstractXpRepository`

---

## 🧪 Required Tests

| Type         | Scope                                       |
|--------------|---------------------------------------------|
| ✅ Unit       | Repo + Notifier logic                       |
| ✅ Widget     | All user interactions                       |
| ✅ Golden     | UI state including FABs and animations      |
| ✅ Scaling    | `Text()` must respect `MediaQuery.textScaleFactorOf` |

---

## 🔐 Firestore Integration Rules

- Use `.withConverter<T>()` — no raw `.data()` or `.map()`
- All models must contain:
  - `createdAt`
  - `updatedAt`
  - `createdBy`
  - `modifiedBy`

---

## 🛡 HIPAA & Security Compliance

- ❌ No Firebase code in widgets
- ✅ All PHI lives in secure Firestore paths
- ✅ `guardFirebaseInitialization()` is required in `main.dart`
- ❌ No GPT/AI usage with PHI

---

## 🧠 Gamification Rules

| Rule | Description |
|------|-------------|
| 🎯 XP Source | `grantXp()` in `AbstractXpRepository` |
| 👩‍⚕️ Action | Only nurse-driven actions trigger XP |
| ❌ No XP | For retries, automation, or non-nurse actions |
| 📊 Tracking | Stored under `users/` and `leaderboards/` |

---

## 🎨 UI Guidelines

- Use **Progressive Disclosure** for secondary info (e.g., notes, history)
- FABs required for major flows (e.g., vitals, notes)
- Animate UI via `animation_tokens.dart`
- Support dark mode, light mode, and mock mode (`AppEnv.isMock`)

---

## 🔁 Mock Mode Standards

- Toggled via `AppEnv.isMock`
- Repositories must provide mock fallbacks
- Golden tests use `FakeFirebase` when applicable

---

## 🚫 Prohibited Patterns

| ❌ Anti-Pattern | 🚫 Description |
|----------------|----------------|
| Logic in UI    | No state/data fetch in widget builds |
| Mutable UI     | No mutable state in widgets           |
| Skipped tests  | No `TODO` or skipped tests in prod    |

---

## 🧭 Provider Usage Guide

### `authControllerProvider`
- Used for:
  - Auth state
  - Login/logout
  - Route access control

### `userProfileProvider`
- Used for:
  - Display/edit of profile fields (name, photo)
  - Avoids Firestore updates triggering router
  - Preferred in all profile UIs
