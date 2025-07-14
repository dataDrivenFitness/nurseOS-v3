# NurseOS Feature Development Guide v2.2

> Comprehensive development handbook covering patterns, testing, UX, gamification, and shift-centric architecture enforcement.

---

## 🧠 Purpose

- Enforce current architecture, UX, and compliance protocols
- Act as definitive development reference
- Prevent reintroduction of deprecated patterns
- **ENFORCE shift-centric patient-nurse relationships** ⭐

---

## ✅ Core Development Protocol (DPP)

🚨 **MANDATORY Process for All Feature Development:**

1. **ASK** for files first - "Which files do you need me to provide?"
2. **ANALYZE** thoroughly - Review current implementation vs. target architecture
3. **PRESENT** changes - Explain what will be modified and why
4. **REQUEST** approval - Get explicit confirmation before proceeding
5. **IMPLEMENT** one file - Make changes to single file only
6. **CONFIRM** completion - Verify changes before moving to next file

**NEVER:**
- ❌ Start generating code immediately
- ❌ Make assumptions about current implementation
- ❌ Modify multiple files simultaneously
- ❌ Skip the analysis and approval phases

---

## 🧾 Architecture & File Rules

### **Folder Structure**
```
lib/core/       ← env, theme, tokens, providers
lib/features/   ← feature slices (patient, gamification, schedule)
lib/shared/     ← shared widgets, utils, tokens
```

### **Module Organization**
- `features/gamification/` handles XP, levels, badges
- `features/schedule/` manages ALL patient-nurse relationships ⭐
- `core/theme/animation_tokens.dart` for motion timing
- `shared/widgets/` for reusable UI components

---

## 🚫 **CRITICAL Anti-Patterns** ⭐

### **Shift-Centric Architecture Violations**
- ❌ **NEVER use `assignedNurses` field** in Patient model
- ❌ **NEVER create direct patient-nurse relationships** outside of shifts
- ❌ **NEVER query patients.where('assignedNurses', arrayContains: nurseId)**
- ❌ **NEVER add `assignedNurses` to any Patient-related code**

### **Required Pattern Enforcement**
```dart
// ✅ CORRECT: Query patients via shifts
1. Get shifts where assignedTo == nurseId
2. Collect assignedPatientIds from shifts  
3. Query patients where id in [patientIds]

// ❌ WRONG: Direct patient-nurse relationship
patients.where('assignedNurses', arrayContains: nurseId) // FORBIDDEN
```

### **Legacy Anti-Patterns**
- ❌ No direct Firebase in `Notifier` or widgets
- ❌ No XP from system events (only nurse actions)
- ❌ No hardcoded roles in frontend

---

## ⚙️ State Management Rules

### **Riverpod Patterns**
- Use `AsyncNotifier` for async state with mutations
- Use `Notifier` for synchronous state management
- Firebase never used directly in widgets
- Async UI must use `.when()` and `AsyncValue.guard()`

### **Provider Organization**
```dart
// Repository providers
@riverpod
PatientRepository patientRepository(PatientRepositoryRef ref) => ...;

// Controller providers  
@riverpod
class PatientController extends _$PatientController {
  // State management logic
}

// UI state providers
@riverpod
class FeatureFlagController extends _$FeatureFlagController {
  // Feature flag management
}
```

---

## 🧱 Model Standards

### **Required Patterns**
- Use `freezed` for all data models
- Use `withConverter()` for Firestore models
- Never serialize manually in widget layer
- Extensions go in separate files (`_extensions.dart`)

### **Model Structure**
```dart
@freezed
class ExampleModel with _$ExampleModel {
  const factory ExampleModel({
    required String id,
    @Default(false) bool someFlag,
    // ... other fields
  }) = _ExampleModel;

  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);
}
```

---

## 🏅 Gamification System Rules

### **XP & Rewards**
- Only nurse actions can trigger XP (never system events)
- XP stored in `users/` and `leaderboards/` collections
- No leaderboard UI on mobile (web admin only)
- Use `AbstractXpRepository` with mock/live split

### **Implementation Pattern**
```dart
// ✅ CORRECT: XP from nurse action
await xpRepository.awardXp(
  userId: currentUser.id,
  points: 10,
  reason: 'completed_vitals_entry',
  metadata: {'patientId': patient.id},
);

// ❌ WRONG: XP from system event
// Never award XP for login, app opens, automatic syncs, etc.
```

---

## 🎨 UX & Theme Guidelines

### **Typography System**
- All `Text()` widgets must scale via `MediaQuery`
- Use `AppTypography.textTheme` for consistent fonts
- Test with 0.8x, 1x, 1.3x, 2x font scales
- Minimum text size: 13px, Maximum line length: ~72 chars

### **Color & Spacing**
- Use `AppColors` extension for semantic colors
- Use `SpacingTokens` for consistent spacing (sm, md, lg, xl)
- All components must support dark/light themes
- Never hardcode hex color values

### **Button Standards**
- Use `PrimaryButton` for primary actions
- Use `OutlinedButton` or `TextButton` for secondary actions
- Use `SegmentedButton` for filters or mode switching
- Minimum tap target: 48px

### **Layout Patterns**
- Use `Slivers` in scrollable lists for performance
- Use `FormCard` for grouped form elements
- Use `NurseScaffold` for consistent screen structure
- Prefer 8pt spacing scale throughout

### **Animation Standards**
- Use `animation_tokens.dart` for microinteractions
- Transition patterns: fade, slide, scale (avoid bouncing)
- Animate appearance with fade-in or scale-in
- Keep animation durations under 300ms

### **Progressive Disclosure**
- Use for Notes, History, Alerts, and non-critical data
- Collapse long text under "... more" links
- Avoid expanding >3 items at once
- Show critical information inline (no popups)

### **Floating Action Button**
- Use only where nurse is initiating data entry
- Show FAB on Vitals, Notes, Care Plans
- Hide FAB on read-only views
- Only one FAB per screen

---

## 🧪 Testing Standards

### **Required Tests per Feature**
- **Unit tests** - Business logic and state management
- **Widget tests** - User interactions and UI behavior
- **Golden tests** - Visual regression testing

### **Shift-Centric Testing Requirements** ⭐
```dart
group('Shift-Centric Patient Repository', () {
  test('returns patients from nurse shifts only', () async {
    // Test multi-step query logic
  });
  
  test('returns empty when nurse has no shifts', () async {
    // Test no-assignment scenario
  });
  
  test('handles large caseloads efficiently', () async {
    // Performance test for 50+ patients
  });
  
  test('updates patient list when shifts change', () async {
    // Real-time update test
  });
});
```

### **Additional Testing Rules**
- FAB and animation states must appear in golden tests
- Font scaling must be verified in widget tests (0.8x, 1x, 1.3x, 2x)
- XP/microanimation triggers must be testable
- All async operations must be tested with both success and error states

### **Mock Data Patterns**
```dart
// ✅ CORRECT: Multi-agency mock data
final mockShifts = [
  ScheduledShift(agencyId: 'metro_hospital', assignedTo: nurseId),
  ScheduledShift(agencyId: null, assignedTo: nurseId), // Independent
];

// ✅ CORRECT: Patient access via shifts
final mockPatientRepository = MockPatientRepository()
  ..stub((repo) => repo.getPatientsForNurse(nurseId))
  .thenAnswer((_) async => patientsFromShifts);
```

---

## 🔍 Code Review Checklist

### **Automatic Rejection Criteria**
Immediately flag and reject code containing:
1. **`assignedNurses` anywhere in Patient-related code**
2. **Direct patient-nurse relationship queries**
3. **Patient model updates that add nurse assignment fields**
4. **Repository methods that bypass shift-based queries**

### **Required Validation Questions**
1. "How does this code handle patient-nurse relationships?"
2. "Are patients being queried through scheduled shifts?"
3. "Does this support both agency and independent nurses?"
4. "Is this HIPAA-compliant with shift-based access control?"

### **Performance Standards**
- **Patient List**: Must load in <2 seconds for 50+ patients
- **Real-time Updates**: Shift changes propagate within 1 second
- **Firestore Costs**: Multi-step queries must not exceed budget

---

## 📄 Documentation Requirements

### **Flag New Patterns For:**
- `NurseOS_v2_ARCHITECTURE.md` - Architectural decisions
- `NurseOS_Refactor_Roadmap_v2.md` - Feature progress
- `Shift_Centric_Architecture_Reference.md` - Implementation details
- `HIPAA_Readiness_Checklist.md` - Compliance impacts

### **Documentation Standards**
- All new features require architecture documentation
- Breaking changes must be documented in roadmap
- HIPAA impacts must be assessed and documented
- Migration scripts must be documented and tested

---

## 🚀 Feature Development Workflow

### **Starting a New Feature**
1. Review relevant architecture documents
2. Check current roadmap status and dependencies
3. Design with shift-centric patterns from the start
4. Create comprehensive test plan
5. Follow DPP protocol for implementation

### **Shift Management Features**
1. Always use agency-scoped data models
2. Support both independent and agency nurses
3. Implement proper agency isolation
4. Include audit trails for HIPAA compliance

### **Independent Nurse Support**
- Detect user type and adapt UI accordingly
- Support dual-mode operation (agency + independent)
- Enable self-service shift creation
- Maintain clear business context

---

## 💬 Communication Guidelines

### **When Discussing Architecture**
- Always emphasize shift-centric benefits (HIPAA, flexibility, accuracy)
- Explain reasoning behind multi-step queries
- Address performance concerns proactively
- Highlight independent nurse support as key differentiator

### **When Rejecting Code**
- Be firm but helpful about shift-centric requirements
- Provide specific code examples of correct patterns
- Reference architecture documents for detailed guidance
- Offer concrete solutions rather than just pointing out problems

---

**Remember: The shift-centric architecture is not just a technical choice - it's a fundamental business requirement that enables independent nurses, improves HIPAA compliance, and provides accurate audit trails. Enforce it consistently and help developers understand the benefits.**