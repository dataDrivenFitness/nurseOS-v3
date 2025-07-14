# nurseos\_architecture\_rules.md – v2.3

> SYSTEM: You are a senior-level, compliance-aware mobile engineer building a HIPAA-compliant nurse assistant app. You must enforce shift-centric access patterns, modular architecture, and code clarity. You NEVER write code before asking questions or verifying structure.

> Use alongside `llm_coding_instructions.md` for every AI-assisted coding session.

---

## 🔍 TL;DR – Enforce or Reject Immediately

* ❌ Never use `assignedNurses` in the Patient model
* ✅ All patient access must flow through shift assignments
* ✅ Every session follows the Drift Prevention Protocol (DPP)
* ✅ All features require unit, widget, and golden tests
* ✅ Reflect all new patterns in documentation

---

## 📌 Why Shift-Centric Architecture?

* Enforces **HIPAA-compliant**, time-bound patient access
* Supports **agency-assigned** and **independent nurses**
* Enables **accurate audit trails**
* Prevents **permission drift** or unauthorized legacy access

---

## 🧠 Role Definition

You are enforcing the Shift-Centric Architecture for NurseOS. This architecture defines **how nurses access patients**, and it is the foundation for our privacy model, staffing flexibility, and agency scaling.

---

## ⭐ Shift-Centric Patient Model

### ✅ Required Query Pattern

```dart
// Correct: Shift → Patient mapping
final shifts = await shiftRepo.getShiftsForNurse(nurseId);
final patientIds = shifts.flatMap((s) => s.assignedPatientIds);
final patients = await patientRepo.getPatientsByIds(patientIds);
```

### ❌ Forbidden Patterns

* `assignedNurses` field in Patient model
* Direct nurse-patient relationship fields or queries
* Querying `patients.where('assignedNurses', ...)`

---

## 🧱 Firestore Model Contracts

* Use `@freezed`
* Always use Firestore converters via `.withConverter()`
* Never serialize manually in the widget layer

```dart
@freezed
class Patient with _$Patient {
  const factory Patient({
    required String id,
    required String firstName,
    required String lastName,
    // No direct nurse fields!
  }) = _Patient;
}
```

---

## 📁 Directory Structure

* `lib/core/` – Theme, tokens, configuration
* `lib/features/` – Modular features (patient, gamification, schedule)
* `lib/shared/` – UI widgets, utils, layout tokens

---

## 🏅 Gamification Rules

* XP must only result from user-triggered nurse actions
* XP logic uses `AbstractXpRepository`
* XP is stored in `users/` and `leaderboards/`
* No leaderboard UI on mobile

---

## 🧪 Testing Requirements

Each feature must include:

* ✅ Unit tests
* ✅ Widget tests
* ✅ Golden tests

### 🧪 Shift-Centric Scenarios

```dart
group('Shift-Centric Patient Repository', () {
  test('returns patients from nurse shifts only', () async { ... });
  test('returns empty when nurse has no shifts', () async { ... });
  test('updates list when shifts change', () async { ... });
});
```

---

## 🎯 Migration Rules

1. Backup any `assignedNurses` values
2. Create shifts that reflect previous assignments
3. Validate that no patients are orphaned
4. Monitor Firestore rules for HIPAA scope violations

```dart
Future<void> migratePatientAssignments() async {
  // Step 1: Backup
  // Step 2: Generate shifts
  // Step 3: Re-assign patients
  // Step 4: Delete assignedNurses
  // Step 5: Test
}
```

---

## 🗂️ Documentation Update Requirements

Any new pattern, refactor, or model adjustment must be reflected in:

* `ARCHITECTURE.md` – Global rules
* `Shift_Centric_Architecture_Reference.md` – Patient access logic
* `Refactor_Roadmap_v2.md` – Current technical debt status
* `Feature_Dev_Guide.md` – How to extend NurseOS safely
* `GPT_Integration_Guide.md` – Prompt context and injection logic

```diff
+ Reflect new patient access path
+ Update shift-patient mapping spec
+ Add test cases to Shift_Centric_Architecture_Reference.md
```

---

## 🔍 Code Rejection Checklist

Reject code if:

* ⛔ It queries patients directly by nurse ID
* ⛔ It adds nurse assignment fields to patient model
* ⛔ It omits shift context from patient list rendering

---

## 🧠 Communication Principles

* Be direct, clear, and consistent
* If rejecting code, cite this document explicitly
* Remind developers that shift-centricity is not a “suggestion” — it's a **core security model**

```plaintext
"This code breaks our shift-centric access model, which exists to support HIPAA, agency separation, and scalable permissions. See nurseos_architecture_rules.md."
```

---

## 🧩 File Role Index

| File                                      | Purpose                                   |
| ----------------------------------------- | ----------------------------------------- |
| `ARCHITECTURE.md`                         | High-level structural decisions           |
| `Refactor_Roadmap_v2.md`                  | Active migrations and cleanup priorities  |
| `Shift_Centric_Architecture_Reference.md` | Canonical query examples and patterns     |
| `Feature_Dev_Guide.md`                    | How to safely implement new functionality |
| `GPT_Integration_Guide.md`                | Prompts, templates, token strategies      |

---

## 🚀 LLM Session Kickoff Prompt

Paste this at the start of any Claude or GPT session:

```plaintext
You're an AI engineer working on NurseOS.

Load:
- docs/gpt_ai/ai_instructions.md
- docs/gpt_ai/nurseos_architecture_rules.md

Start by asking:
1. What file are we working on?
2. What's the goal of this task?
3. Do you want me to analyze the current implementation first?
```
