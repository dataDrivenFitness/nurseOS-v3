> ⚠️ UPDATE NOTE: This document has been synced to NurseOS v2 architecture.
> UPDATED: Updated paths to reflect lib/features/*, adjusted interface and toggle examples for v2 layout.

...

# 📘 NurseOS Feature Dev Guide v2.1 – Firebase Edition

This update reflects our transition to a Firebase-integrated development model while preserving the modular, testable architecture defined in v2.0.

---

## ✅ Feature Build Principles

* Each feature module should support both:

  * 🔁 **Mock mode** (default dev/test)
  * 🔗 **Firebase live mode** (toggled via `.env.dart`)

* All services must use interfaces for swappable backends (`AbstractNoteService`, etc.)

---

## 🧪 Updated Mock Management

Still required for:

* Vitals
* Care Plans
* Assessments

**Must include:**

* `MockScenarioBuilder`
* `mock_constants.dart` UIDs
* Toggled success/failure logic

---

## 🔐 Firebase-Enabled Features

| Feature         | Source          | Notes                         |
| --------------- | --------------- | ----------------------------- |
| Auth            | Firebase Auth   | Email/pass only (no SSO yet)  |
| Shift Notes     | Firestore       | Use `wasAiGenerated` + audit  |
| Sentiment Notes | Firestore       | Stored in `notes/` collection |
| Patient Records | Firestore       | With `assignedNurses[]` field |
| GPT Integration | Still mock-only | All output must be editable   |

---

## 🔄 Firebase-Pending Modules (Read-Only Prep)

| Feature    | Status       | Notes                                         |
| ---------- | ------------ | --------------------------------------------- |
| Vitals     | 🔒 Read-Only | Firestore structure aligned, write blocked    |
| Care Plans | 🔒 Read-Only | Static structure only, no checklist logic yet |

> These modules include Firebase-read hooks but retain `mock_*` for editing and testing until validation is complete.

---

## 📁 Updated File Requirements

### /services/

* Add `firebase_*_service.dart` files
* Interfaces must remain in `abstract_*_service.dart`

### /state/

* Use `.env.dart` flag: `useMockServices`
* Providers must swap between mock and live

### /models/

* Annotate for Firestore: `fromJson`, `toJson`
* Keep model logic pure (no Firestore SDK calls)

### /mock\_data/

* Still required for all dev/test flows
* Must support full patient lifecycle

---

## 🧭 Platform Support (Revised)

| Platform | Status   | Notes                                                  |
| -------- | -------- | ------------------------------------------------------ |
| iOS      | ✅ Active | Primary UI design and release target                   |
| Android  | 🟡 Beta  | Supported for dev testing, Firebase-ready modules only |
| Web      | ❌ Off    | Deferred (Phase 8+)                                    |

> Developers may test mock and Firebase services on Android devices/emulators. Final production UX remains iOS-optimized.

---

## 🧠 GPT Use Policy (Reaffirmed)

* GPT outputs must:

  * Be stored via a `firebase_shift_note_repository.dart` with metadata
  * Never be directly written to Firestore from GPT
  * Be flagged `wasAiGenerated = true`
  * Trigger a log in `audit_log/`

* Editable confirmation UI is required before saving

---

*Firebase-powered. Modular-first. Still nurse-safe.*


<!-- v2.1 update – Jun 22 -->

## 🔁 Repository Return Type Enforcement

* All repositories must return `Either<Failure, T>` for consistency and retry-safe UI.
* This applies to:
  - PatientRepository
  - VitalsRepository
  - ShiftNoteRepository
  - Future features (CarePlans, Tasks)

## 🎮 XP Hook Placement

* XP logic should currently live inside the `.save()` method of feature repositories (e.g., `MockPatientRepository.save()`).
* This preserves modularity and aligns with event-driven XP attribution (based on nurse actions).

---

## 🧠 Persistent Riverpod Providers – NurseOS v2 Pattern

### When to Use `@Riverpod(keepAlive: true)`

Use `keepAlive: true` when the provider manages **global or cross-screen state** that must:
- Survive screen transitions
- Be globally available (theme, auth, routing)
- Avoid reset/rebuild due to lack of listeners

---

### ✅ Required for These Providers

| Provider               | Reason |
|------------------------|--------|
| `AuthController`       | Tracks logged-in nurse across all screens |
| `ThemeController`      | Ensures stable UI mode (light/dark) |
| `RouteNotifier`        | Maintains navigation guards and deep-link state |

---

### 🔁 Optional for These (Only if state used across screens)

| Provider                      | When to use `keepAlive` |
|-------------------------------|--------------------------|
| `UserPreferencesController`   | If language, notification, or accessibility settings are shared |
| `ShiftSessionController`      | If shift timing/session data must persist across tabs |
| `AppUpdateNotifier`           | If update prompts are shown from multiple entry points |

---

### ❌ Avoid `keepAlive` for:
- Screen-local forms (Vitals entry, Patient notes)
- One-off UI state (FAB visibility, toggles scoped to one view)
- Any provider used in only one widget tree

---

> 📌 **Enforcement**: All new global providers must be reviewed for `keepAlive` scope and explicitly tagged in code and `Feature_Dev_Guide_v2-2.md`.
