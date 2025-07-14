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

| Type     | Required? | Testing Pattern |
|----------|-----------|-----------------|
| Unit     | ✅        | Repository + model logic |
| Widget   | ✅        | User interactions |
| Golden   | ✅        | Visual consistency + scaling |

---

## 🏥 **Shift-Centric Architecture (v2.0)**

### **Core Principle: Agency-Scoped Shifts**

**Critical:** Patient access is controlled through shifts, not direct assignments. Each shift belongs to exactly one agency OR is independent.

```dart
// ✅ CORRECT: Access patients via shifts
1. Get shifts where assignedTo == nurseId
2. Collect assignedPatientIds from shifts  
3. Query patients where id in [patientIds]

// ❌ FORBIDDEN: Direct patient-nurse relationships
patients.where('assignedNurses', arrayContains: nurseId) // NEVER USE
```

### **Multi-Shift Daily Model**

Nurses can work multiple shifts per day across different organizational contexts:

```
Nurse's Tuesday Schedule:
├── Metro Hospital Shift (8am-4pm)    [agencyId: 'metro_hospital']
├── Sunrise Care Shift (6pm-10pm)     [agencyId: 'sunrise_care']  
└── Independent Shift (11pm-7am)      [agencyId: null]
```

### **Data Storage Architecture**

```
/agencies/{agencyId}/scheduledShifts/{shiftId}  ← Agency shifts
/independentShifts/{shiftId}                    ← Independent shifts
/scheduledShifts/{shiftId}                      ← Legacy (migration only)
```

### **Shift-Centric Security Benefits**

- ✅ **HIPAA Compliance**: Time-bounded patient access
- ✅ **Agency Isolation**: Complete data separation between organizations
- ✅ **Audit Trail**: Clear shift-based access logging
- ✅ **Independent Support**: Self-managed patient relationships

### **Patient Assignment Rules**

```dart
// Agency patient → Agency shift (same agency)
if (patient.agencyId == shift.agencyId) ✅

// Independent patient → Independent shift  
if (patient.agencyId == null && shift.agencyId == null) ✅

// Cross-agency assignment FORBIDDEN
if (patient.agencyId != shift.agencyId) ❌
```

---

## 👩‍⚕️ **Independent Nurse Support**

### **Three Nurse Types**

| Type | Description | Capabilities |
|------|-------------|--------------|
| **Agency-Only** | `isIndependentNurse: false` | Request/work agency shifts only |
| **Independent-Only** | `isIndependentNurse: true`, no agencies | Create own shifts, manage own patients |
| **Dual-Mode** | `isIndependentNurse: true` + agencies | Both agency work AND independent practice |

### **UserModel Extensions**

```dart
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    // ... existing fields ...
    
    // Independent nurse support
    @Default(false) bool isIndependentNurse,
    String? businessName,
    
    // Multi-agency support  
    String? activeAgencyId,
    @Default({}) Map<String, AgencyRoleModel> agencyRoles,
  }) = _UserModel;
}
```

---

## 🔄 **Navigation Architecture (v3)**

### **New 4-Tab Navigation**

Replaces current 5-tab system when `navigation_v3` feature flag is enabled:

```
Current: [Tasks] [Schedule] [Patients] [Profile] [Admin]
New:     [Available Shifts] [My Shift] [Profile] [Admin]
```

### **Feature Flag Integration**

```dart
// AppShell with feature flag routing
final useNewNavigation = ref.watch(featureFlagProvider('navigation_v3'));

return useNewNavigation 
  ? ThreeTabNavigation()   // New shift-centric navigation
  : AppShell(child: child); // Current navigation
```

### **My Shift Screen Structure**

```
My Shift
├── [Patients] tab    ← Shift-filtered patient list
└── [Tasks] tab       ← Gamified task management
```

---

## 🎮 **Gamification Integration**

### **XP Attribution Rules**

- ✅ **Nurse actions only**: Task completion, patient care activities
- ❌ **No system events**: Automatic XP generation forbidden
- ✅ **Shift-based tracking**: XP tied to specific work sessions

### **Task-Centric Gamification**

```dart
// XP triggers within shift context
- Complete vitals assessment: 5 XP
- Document patient notes: 8 XP  
- Finish medication round: 10 XP
- Complete full shift: 25 XP
```

### **Separation of Concerns**

```
users/{uid}                    ← Professional data only
gamificationProfiles/{uid}     ← XP, badges, achievements
```

---

## 🔒 **Security & Compliance**

### **HIPAA-Ready Patterns**

- **Time-bounded access**: Patient data only during shift hours
- **Agency isolation**: No cross-agency data visibility
- **Audit logging**: All patient access tied to shifts
- **Independent privacy**: Nurse-controlled patient relationships

### **Firestore Security Rules**

```javascript
// Agency shift access
match /agencies/{agencyId}/scheduledShifts/{shiftId} {
  allow read, write: if userIsAgencyMemberOrAssignedNurse(agencyId, shiftId);
}

// Independent shift access  
match /independentShifts/{shiftId} {
  allow read, write: if resource.data.createdBy == request.auth.uid;
}
```

---

## 📋 **Development Standards**

### **Anti-Patterns (Forbidden)**

- ❌ **assignedNurses field** in Patient model
- ❌ **Direct patient-nurse queries** outside shift context
- ❌ **Cross-agency data access** in any form
- ❌ **XP from system events** (only nurse actions)

### **Required Patterns**

- ✅ **Shift-centric patient queries** always
- ✅ **Agency boundary enforcement** in all patient operations
- ✅ **Extension methods** for model logic (keep models clean)
- ✅ **Feature flag** controlled rollouts

### **Testing Requirements**

```dart
// Required shift-centric tests
group('Shift-Centric Patient Repository', () {
  test('returns patients from nurse shifts only');
  test('enforces agency boundaries');  
  test('handles independent nurse patients');
  test('prevents cross-agency access');
});
```

---

## 🚀 **Migration Path**

### **Phase 1: Foundation** ✅
- [x] Extended UserModel with independent nurse fields
- [x] Enhanced ScheduledShiftModel with agency scoping
- [x] Created agency-scoped Firestore converters
- [x] Built feature flag system for navigation

### **Phase 2: Navigation** 🔄
- [ ] Implement Available Shifts Screen
- [ ] Build My Shift Screen with sub-tabs
- [ ] Create shift creation wizard
- [ ] Add patient assignment workflows

### **Phase 3: Data Migration** 📋
- [ ] Migrate existing shifts to agency collections
- [ ] Update patient assignments to shift-based model
- [ ] Remove deprecated assignedNurses fields
- [ ] Validate data integrity across all collections

---

This architecture ensures scalable, compliant, and maintainable nursing workflows while supporting independent practice growth and multi-agency operations.