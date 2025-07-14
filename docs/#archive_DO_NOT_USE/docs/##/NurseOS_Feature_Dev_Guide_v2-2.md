# 📘 NurseOS Feature Dev Guide v2.2.2 – Shift-Centric Architecture Edition

This guide reflects our transition to **shift-centric patient relationships** and **agency-scoped data architecture** while preserving the modular, testable patterns defined in v2.0.

---

## ✅ Feature Build Principles

* Each feature module should support both:

  * 🔁 **Mock mode** (default dev/test)
  * 🔗 **Firebase live mode** (toggled via `.env.dart`)

* All services must use interfaces for swappable backends (`AbstractShiftRepository`, `AbstractPatientRepository`, etc.)

* **NEW:** All patient access must be **shift-centric** (no direct patient-nurse assignments)

---

## 🏥 **Shift-Centric Development Patterns**

### **🚫 CRITICAL Anti-Patterns**

**These patterns are FORBIDDEN and will break the architecture:**

```dart
// ❌ NEVER: Direct patient-nurse relationships
patients.where('assignedNurses', arrayContains: nurseId)

// ❌ NEVER: Cross-agency patient access
if (patient.agencyId != shift.agencyId) {
  // This should be prevented at the data layer
}

// ❌ NEVER: Patient access without shift context
final patients = await patientRepo.getAllPatients(); // Too broad

// ❌ NEVER: Agency field in Patient model
const factory Patient({
  List<String>? assignedNurses, // FORBIDDEN FIELD
});
```

### **✅ Required Patterns**

**All patient access must follow this pattern:**

```dart
// ✅ CORRECT: Shift-centric patient access
1. Get shifts where assignedTo == nurseId
2. Collect assignedPatientIds from shifts  
3. Query patients where id in [patientIds]

// Example implementation:
Future<List<Patient>> getShiftPatients(String nurseId) async {
  final shifts = await shiftRepo.getUserShifts(nurseId);
  final patientIds = shifts.expand((s) => s.assignedPatientIds).toList();
  return await patientRepo.getPatientsByIds(patientIds);
}
```

### **🔒 Agency Boundary Enforcement**

```dart
// ✅ CORRECT: Agency-scoped operations
class ShiftPatientService {
  Future<void> assignPatientToShift(String patientId, String shiftId) async {
    final patient = await patientRepo.getById(patientId);
    final shift = await shiftRepo.getById(shiftId);
    
    // Enforce agency boundaries
    if (patient.agencyId != shift.agencyId) {
      throw AgencyBoundaryViolation('Cannot assign cross-agency patient');
    }
    
    // Independent nurse boundary check
    if (patient.agencyId == null && shift.agencyId != null) {
      throw IndependentPatientViolation('Independent patient needs independent shift');
    }
    
    await shiftRepo.addPatientToShift(shiftId, patientId);
  }
}
```

---

## 🧪 Updated Mock Management

### **Shift-Centric Mock Data**

Still required for all features, now with shift context:

```dart
class MockShiftRepository implements AbstractShiftRepository {
  // Mock shifts with proper agency scoping
  final Map<String, List<ScheduledShiftModel>> _agencyShifts = {
    'metro_hospital': [/* agency shifts */],
    'sunrise_care': [/* agency shifts */],
  };
  
  final List<ScheduledShiftModel> _independentShifts = [/* independent shifts */];
  
  @override
  Future<List<ScheduledShiftModel>> getUserShifts(String nurseId) async {
    // Return shifts from all agencies + independent
    final allShifts = <ScheduledShiftModel>[];
    
    // Add agency shifts
    for (final agencyShifts in _agencyShifts.values) {
      allShifts.addAll(agencyShifts.where((s) => s.assignedTo == nurseId));
    }
    
    // Add independent shifts
    allShifts.addAll(_independentShifts.where((s) => s.assignedTo == nurseId));
    
    return allShifts;
  }
}
```

### **Mock Scenario Builder Updates**

```dart
class MockScenarioBuilder {
  static ScheduledShiftModel createAgencyShift({
    required String agencyId,
    required String nurseId,
    List<String>? patientIds,
  }) {
    return ScheduledShiftModel(
      id: 'mock_shift_${DateTime.now().millisecondsSinceEpoch}',
      agencyId: agencyId,
      assignedTo: nurseId,
      isUserCreated: false,
      assignedPatientIds: patientIds ?? [],
      // ... other required fields
    );
  }
  
  static ScheduledShiftModel createIndependentShift({
    required String nurseId,
    List<String>? patientIds,
  }) {
    return ScheduledShiftModel(
      id: 'mock_independent_${DateTime.now().millisecondsSinceEpoch}',
      agencyId: null, // Independent shift
      assignedTo: nurseId,
      isUserCreated: true,
      assignedPatientIds: patientIds ?? [],
      // ... other required fields
    );
  }
}
```

---

## 🔐 Firebase-Enabled Features

| Feature         | Source          | Agency-Scoped? | Notes                         |
| --------------- | --------------- | -------------- | ----------------------------- |
| Auth            | Firebase Auth   | No             | Email/pass only (no SSO yet)  |
| **Shift Management** | **Firestore** | **✅ Yes** | **Agency-scoped collections** |
| **Patient Access** | **Firestore** | **✅ Yes** | **Via shifts only** |
| Shift Notes     | Firestore       | ✅ Yes | Use `wasAiGenerated` + audit  |
| Sentiment Notes | Firestore       | ✅ Yes | Stored in `notes/` collection |
| GPT Integration | Still mock-only | No | All output must be editable   |
| **Independent Shifts** | **Firestore** | **✅ Isolated** | **Separate collection** |
| **Visit Check-ins (EVV)** | **Firestore** | **✅ Yes** | **Shift-scoped GPS tracking** |
| **Progress Notes** | **Firestore** | **✅ Yes** | **HIPAA-safe, shift-linked** |

---

## 🔄 Firebase Collection Architecture

### **Agency-Scoped Collections**
```
/agencies/{agencyId}/scheduledShifts/{shiftId}
/agencies/{agencyId}/patients/{patientId}
/agencies/{agencyId}/notes/{noteId}
/agencies/{agencyId}/visits/{visitId}
```

### **Independent Collections**
```
/independentShifts/{shiftId}
/users/{userId}/ownedPatients/{patientId}
/users/{userId}/independentNotes/{noteId}
```

### **Global Collections**
```
/users/{userId}                    ← User profiles and agency affiliations
/gamificationProfiles/{userId}    ← XP, badges (separated from professional data)
```

---

## 📁 Updated File Requirements

### **/models/**

**✅ Required Shift Models:**
```dart
@freezed
abstract class ScheduledShiftModel with _$ScheduledShiftModel {
  const factory ScheduledShiftModel({
    required String id,
    String? agencyId,                    // NEW: Agency scoping
    required String assignedTo,
    @Default(false) bool isUserCreated, // NEW: Independent nurse support
    String? createdBy,                  // NEW: Audit trail
    List<String>? assignedPatientIds,   // Core: Patient relationships
    // ... other fields
  }) = _ScheduledShiftModel;
}
```

**❌ Forbidden Patient Fields:**
```dart
// NEVER add these fields to Patient model:
List<String>? assignedNurses,  // FORBIDDEN
String? primaryNurse,          // FORBIDDEN
```

### **/services/**

**✅ Required Repository Interfaces:**
```dart
abstract class AbstractShiftRepository {
  Future<List<ScheduledShiftModel>> getUserShifts(String nurseId);
  Future<List<ScheduledShiftModel>> getAgencyShifts(String agencyId);
  Future<List<ScheduledShiftModel>> getIndependentShifts(String nurseId);
  Future<void> assignPatientToShift(String shiftId, String patientId);
  Future<void> createAgencyShift(String agencyId, ScheduledShiftModel shift);
  Future<void> createIndependentShift(ScheduledShiftModel shift);
}

abstract class AbstractPatientRepository {
  // NEW: Shift-centric patient access
  Future<List<Patient>> getShiftPatients(String shiftId);
  Future<List<Patient>> getPatientsForShifts(List<String> shiftIds);
  
  // Agency-scoped patient management
  Future<List<Patient>> getAgencyPatients(String agencyId);
  Future<List<Patient>> getIndependentPatients(String nurseId);
  
  // Remove these methods (direct access forbidden):
  // Future<List<Patient>> getAssignedPatients(String nurseId); ❌
  // Future<void> assignPatientToNurse(String patientId, String nurseId); ❌
}
```

### **/state/**

**✅ Provider Updates:**
```dart
// Shift-centric patient provider
@riverpod
Future<List<Patient>> shiftPatients(ShiftPatientsRef ref, String shiftId) async {
  final repo = ref.watch(patientRepositoryProvider);
  return await repo.getShiftPatients(shiftId);
}

// Multi-shift nurse schedule
@riverpod
Future<List<ScheduledShiftModel>> nurseShifts(NurseShiftsRef ref, String nurseId) async {
  final repo = ref.watch(shiftRepositoryProvider);
  return await repo.getUserShifts(nurseId);
}

// Agency-scoped shift management
@riverpod
Future<List<ScheduledShiftModel>> agencyShifts(AgencyShiftsRef ref, String agencyId) async {
  final repo = ref.watch(shiftRepositoryProvider);
  return await repo.getAgencyShifts(agencyId);
}
```

### **/mock\_data/**

**✅ Enhanced Mock Requirements:**
```dart
class MockConstants {
  // Agency IDs for multi-agency testing
  static const String metroHospitalId = 'metro_hospital';
  static const String sunriseCareId = 'sunrise_care';
  
  // User IDs with different agency affiliations
  static const String agencyOnlyNurseId = 'nurse_agency_only';
  static const String independentNurseId = 'nurse_independent';
  static const String dualModeNurseId = 'nurse_dual_mode';
  
  // Mock shift scenarios
  static List<ScheduledShiftModel> get mockAgency