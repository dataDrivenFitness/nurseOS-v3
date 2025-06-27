# 🛠️ NurseOS Refactor Roadmap v2

Tracks transition from legacy v1 patterns to modular, testable, and HIPAA-aligned v2 architecture.

---

## ✅ Phase 1: Stabilization

- [x] Strip legacy `home/` module
- [x] Delete all v1 Firebase calls
- [x] Introduce `guardFirebaseInit()` in `main.dart`
- [x] Use `.withConverter<T>()` in all Firestore reads/writes
- [x] Refactor Firestore models to `freezed` format

---

## ⚙️ Phase 2: Modular Architecture

- [x] Move feature logic into `lib/features/`
- [x] Isolate theme into `core/theme/`
- [x] Relocate shared UI to `lib/shared/widgets/`
- [x] Remove `core/utils/` (replace with feature-local logic)
- [x] Introduce `AbstractXpRepository`

---

## 🎨 Phase 3: UX + Animation

- [ ] Replace v1 gestures with microinteraction patterns
- [x] Add FABs to Notes, Vitals
- [x] Use Progressive Disclosure for History and Notes
- [x] Apply `MediaQuery.textScalerOf()` to all `Text()`

---

## 🔐 Phase 4: HIPAA Compliance Finalization

- [x] Implement all items in `HIPAA_Readiness_Checklist.md`
- [x] Ensure prompt redaction for GPT interactions
- [ ] Add tests for backup/restore failover paths
- [x] Lock test environments to mock data only

---

## 🧪 Final Phase: Testing Expansion

- [x] Add golden tests for all gamified flows
- [x] Enforce scaling compliance via `MediaQuery`
- [ ] Add CI gates to fail on missing widget tests

---

## 📦 Deprecated Patterns (Now Removed)

- ❌ `home/` routing shell
- ❌ Manual Firestore `.data()` parsing
- ❌ Legacy auth with custom claims

---

## ✅ [v2.0.6] Auth/Profile State Decoupling

- Removed profile update logic from `authController`
- Introduced `userProfileProvider` for display-only state
- Prevented GoRouter resets on Firestore writes
- Updated `profile_screen.dart` and `edit_profile_form.dart` accordingly
