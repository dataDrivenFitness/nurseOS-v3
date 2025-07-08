
# Firebase Integration Strategy – NurseOS v2

> All Firebase interactions are abstracted, tested, and compliant with HIPAA policies. No direct Firebase calls are allowed in UI layers.

---

## ✅ Core Principles

- 🔒 **HIPAA-Compliant Design**
  - All Firebase access is routed through secure repositories.
  - Use of Firestore, Authentication, and Functions reviewed under BAA.

- 🧱 **Layer Separation**
  - `data/` layer only: No Firebase code in `features/` or `shared/` layers.
  - Riverpod providers bridge repositories and feature logic.

- 🧪 **Test Coverage**
  - Every repository is backed by unit tests and mock implementations.
  - Use mock toggles (`useMock`) in all feature modules.

---

## 🔧 Authentication

- Uses **Firebase Authentication** (email/password, SSO optional)
- Custom claims injected via Firebase Admin SDK to enforce RBAC
- Reauth enforced for sensitive ops (e.g., data export, deletions)

---

## 🔥 Firestore Usage

- Structured via `withConverter<T>()` for all models (no manual `.data()` or `.map()` calls)
- Collections:
  - `users/` – nurse metadata, XP, roles
  - `patients/` – chart, vitals, notes
  - `logs/` – audit and session logs
  - `leaderboards/` – gamification metrics (admin view only)

- All documents include `createdAt`, `updatedAt`, `createdBy`, `modifiedBy`

---

## 🛠️ Firebase Functions

- All role-sensitive logic (e.g., `grantXp`, `softDeletePatient`) uses Cloud Functions
- Callable Functions return validated DTOs only
- No direct writes from client to protected collections

---

## 🧩 Integration Rules

- All Firebase init is done in `lib/core/firebase/`
- Firebase is initialized in a guarded way using:
  ```dart
  await guardFirebaseInitialization();
  ```
- No Firestore instances in UI or `Notifier` classes – use `RepositoryProvider`

---

## 🧪 Testing Firebase Code

- Use `FakeFirebaseFirestore` and `MockFirebaseAuth` in tests
- All repositories must test:
  - CRUD behavior
  - Auth logic
  - Error handling and retries

---

## 🚨 Security

- Firebase rules versioned in `/firebase/rules/`
- CI pipeline runs `firebase emulators:exec` for rule validation
- Role enforcement is duplicated in both Firestore Rules and backend functions

---
