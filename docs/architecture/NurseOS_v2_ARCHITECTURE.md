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

### **Core Principles**
- All models use `.withConverter<T>()`
- No `.data()` or `.map()` in widgets or controllers
- Required metadata fields: `createdAt`, `updatedAt`, `createdBy`, `modifiedBy`

### **Shift-Centric Data Model** ⭐

**CRITICAL**: Patient-nurse relationships are ONLY defined through shifts.

```dart
// ✅ CORRECT: Shifts define patient assignments
ScheduledShift {
  assignedTo: nurseId,
  assignedPatientIds: [patient1, patient2, patient3]
}

// ❌ DEPRECATED: No direct patient-nurse relationships
Patient {
  // assignedNurses: [...] ← REMOVED
}
```

### **Collection Structure**

#### **Agency-Scoped Collections**
```
/agencies/{agencyId}/
  ├── patients/          ← Patient records (NO assignedNurses field)
  ├── shifts/            ← Available shifts for request
  ├── scheduledShifts/   ← Assigned shifts (defines patient relationships)
  └── workSessions/      ← Nurse work history
```

#### **Global Collections**
```
/users/                  ← Nurse profiles, XP, roles
/leaderboards/          ← Gamification metrics (admin-only)
/auditLogs/             ← HIPAA compliance logs
```

### **Patient Query Pattern** 

**Repository Implementation**:
```dart
// Multi-step query: Shifts → Patient IDs → Patients
@override
Future<List<Patient>> getAllPatients(String nurseId) async {
  // 1. Get nurse's shifts
  final shifts = await _firestore
      .collectionGroup('scheduledShifts')
      .where('assignedTo', isEqualTo: nurseId)
      .get();
  
  // 2. Collect patient IDs
  final patientIds = shifts.docs
      .expand((doc) => doc.data()['assignedPatientIds'] ?? [])
      .toSet();
  
  // 3. Query patients by IDs
  return _firestore
      .collectionGroup('patients')
      .where(FieldPath.documentId, whereIn: patientIds.toList())
      .get()
      .then((snap) => snap.docs.map((doc) => Patient.fromJson(doc.data())));
}
```

---

## ✨ UI System

- Typography scales via `MediaQuery.textScalerOf(context)`  
- App-wide override via `fontScaleControllerProvider`
- Animations from `core/theme/animation_tokens.dart`
- AppShell and route transitions defined via `GoRouter`

---

## 🧪 Testing Standards

Every feature must include:

| Type         | Required? | Purpose                           |
|--------------|-----------|-----------------------------------|
| Unit         | ✅ Yes    | Repository logic, business rules  |
| Widget       | ✅ Yes    | Screen interactions, form validation |
| Golden       | ✅ Yes    | Visual consistency, type scaling |

### **Shift-Centric Testing Requirements**

- **Repository Tests**: Multi-step patient queries
- **Integration Tests**: Shift assignment → patient list updates
- **Performance Tests**: Large caseload query timing
- **Migration Tests**: Data integrity during patient-shift migration

---

## 🔒 HIPAA Compliance

### **Shift-Based Security Benefits**

- **Audit Trail**: Every patient access tied to specific shift
- **Time-Bounded Access**: Patient data only accessible during active shifts
- **Automatic Deprovisioning**: Access ends when shift ends
- **Agency Isolation**: Cross-agency data leakage prevented by shift scope

### **Security Rules Example**
```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /agencies/{agencyId}/patients/{patientId} {
    allow read: if isNurseAssignedToPatientViaShift(agencyId, patientId);
  }
  
  function isNurseAssignedToPatientViaShift(agencyId, patientId) {
    return exists(/databases/$(database)/documents/agencies/$(agencyId)/scheduledShifts/$(getUserActiveShift())) &&
           patientId in get(/databases/$(database)/documents/agencies/$(agencyId)/scheduledShifts/$(getUserActiveShift())).data.assignedPatientIds;
  }
}
```

---

## 🚀 Shift Management Features

### **Agency Nurses**
- Receive shift assignments from admin
- Confirm assigned shifts
- Access patients during shift periods

### **Independent Nurses**
- Create their own shifts (caseload, private duty, recurring visits)
- Assign patients to self-created shifts
- Manage ongoing patient relationships through shift model

### **Admin Portal**
- Bulk assign facility patients to shifts
- Approve nurse shift requests
- Emergency coverage with patient handoff

---

## 📊 Performance Considerations

### **Query Optimization**
- **Collection Group Queries**: Enable cross-agency patient access
- **Firestore Indexes**: Required for `assignedTo + agencyId + startTime`
- **Caching Strategy**: Cache nurse's patient list with shift invalidation
- **Pagination**: Support for large patient caseloads

### **Required Indexes**
```
Collection Group: scheduledShifts
Fields: assignedTo (Ascending), agencyId (Ascending), startTime (Ascending)

Collection Group: patients  
Fields: agencyId (Ascending), location (Ascending), department (Ascending)
```

---

## 🚫 Anti-Patterns

- ❌ **No direct patient-nurse relationships** in Patient model
- ❌ **No Firebase calls in widgets** - use repositories only
- ❌ **No XP from system events** - only nurse-initiated actions
- ❌ **No hardcoded roles** in frontend logic
- ❌ **No `assignedNurses` field** in any Patient-related code

---

## 🎯 Migration Strategy

### **From Patient-Centric to Shift-Centric**

1. **Data Migration**: Create shifts for existing patient assignments
2. **Code Migration**: Update repositories to shift-based queries  
3. **Model Updates**: Remove `assignedNurses` from Patient model
4. **Validation**: Ensure all patients remain accessible to correct nurses

### **Rollback Plan**
- Preserve original patient data during migration
- Maintain backup of `assignedNurses` relationships
- Ability to revert to patient-centric model if critical issues found

---

**This architecture provides a unified, scalable foundation for both agency and independent nursing practice while maintaining HIPAA compliance and optimal performance.**