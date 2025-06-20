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
