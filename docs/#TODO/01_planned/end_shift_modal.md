# 🛠️ End-of-Shift Modal – NurseOS v2

This document defines the complete UX, validation logic, state flow, and file structure for the **End-of-Shift Modal** experience within NurseOS. This replaces the simple "Clock Out" button with a contextual, nurse-centered workflow.

---

## 🧭 Goal

Ensure shift completion is deliberate, auditable, and XP-generating — while minimizing cognitive burden on the nurse. The modal provides:

- Optional **break logging**
- Required **shift checklist validation**
- Gamified feedback on successful completion
- Safe dismissal or resumption if not ready

---

## 🧑‍⚕️ Entry Point

### Trigger
- FAB or inline button labeled:  
  ```dart
  ElevatedButton.icon(
    icon: Icon(Icons.exit_to_app),
    label: Text('Clock Out'),
  );
  ```

### Opens
A **full-screen bottom sheet** (preferred) or large modal with:
- `RoundedRectangleBorder`
- Drag-to-dismiss gesture
- Uses `animation_tokens.dart` for transitions

---

## 🔘 Modal Layout

```dart
EndShiftModal(
  shift: currentShift,
  onSubmit: () => shiftController.completeShift(),
)
```

### Sections

1. **Header**:
   ```
   “End of Shift”
   “Confirm you've wrapped up before clocking out.”
   ```

2. **Optional Actions**:
   - Take Meal Break
   - Take Rest Break  
   (uses `visitLogs/` or `shifts/{shiftId}/breaks/` with timestamps)

3. **Required Checklist**:
   Rendered via `ShiftChecklistValidator`:
   - ✅ All required tasks completed
   - ✅ End-of-shift note submitted
   - ✅ EVV check-out recorded (if enabled)

4. **XP Preview**:
   ```
   🎮 +10 XP when completed
   ```

5. **Primary Button**:
   - Label: `Clock Out & Submit`
   - Disabled until all checklist items are ✅
   - On tap: triggers Firestore writes + XP update

---

## ✅ Validation Rules

### ShiftChecklistValidator

```dart
class ShiftChecklistValidator {
  static bool isComplete({
    required List<TaskModel> tasks,
    required bool noteSubmitted,
    required bool evvCheckedOut,
  }) {
    final hasOpenTasks = tasks.any((t) => t.isRequired && !t.isDone);
    return !hasOpenTasks && noteSubmitted && evvCheckedOut;
  }
}
```

### Controlled via Riverpod:
```dart
final shiftChecklistProvider = Provider.autoDispose<bool>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final noteReady = ref.watch(shiftNoteProvider).value?.submitted ?? false;
  final evvOut = ref.watch(evvProvider).value?.checkedOut ?? false;

  return ShiftChecklistValidator.isComplete(
    tasks: tasks,
    noteSubmitted: noteReady,
    evvCheckedOut: evvOut,
  );
});
```

---

## 🔄 Submit Behavior

### On Tap:
```dart
await ref.read(shiftControllerProvider.notifier).completeShift(shift.id);
await ref.read(xpRepositoryProvider).incrementXp(userId, amount: 10);
await FirebaseFirestore.instance.collection('logs/shifts_complete').add({
  'shiftId': shift.id,
  'nurseId': userId,
  'timestamp': FieldValue.serverTimestamp(),
});
ref.invalidate(currentShiftListProvider);
```

---

## 🎨 Microinteractions

- Checklist icons animate in with fade+scale
- Submit button animates from disabled to enabled
- XP Snackbar: `+10 XP for completing shift!`
- Modal dismisses automatically post-success

---

## 🧪 Required Tests

| Type            | Test Case Description                                    |
|------------------|----------------------------------------------------------|
| Unit Test       | `ShiftChecklistValidator` with all permutations          |
| Widget Test     | Modal opens → checklist reflects state → button enables |
| Golden Test     | Modal shown with checklist, XP preview, and break options |
| XP Trigger Test | XP only granted if checklist valid                       |
| Scaling Test    | Modal respects `textScaleFactor` 0.8–2.0                 |

---

## 📁 File Structure

```
lib/features/shifts/
├── presentation/
│   └── end_shift_modal.dart       // Modal UI
│   └── shift_break_buttons.dart   // Reusable break logger
├── state/
│   └── shift_controller.dart      // completeShift logic
│   └── shift_checklist_provider.dart
├── utils/
│   └── shift_checklist_validator.dart
├── data/
│   └── firebase_shift_repository.dart
```

---

## 🔐 Security / HIPAA Considerations

- No PHI shown in modal
- All audit logs written to `logs/shifts_complete/`
- XP logic lives in `xpRepository`, not widget layer
- Firebase writes use agency-scoped `shifts/{shiftId}` path

---

## 📌 Summary

This modal enables:
- Safer, nurse-validated shift closure
- XP attribution tied to confirmed actions
- A single UX point for breaks, notes, and clock-out
- Reliable removal of shift card after completion

---

> 🎯 _Design with nurse flow in mind. Completion should feel like relief, not more admin._ ✅
