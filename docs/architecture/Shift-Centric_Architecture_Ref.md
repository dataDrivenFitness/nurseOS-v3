# 🏥 Shift-Centric Architecture Reference Guide

**Document Version:** 1.0  
**Date Created:** January 13, 2025  
**Status:** 🟢 Architectural Standard  
**Purpose:** Comprehensive reference for shift-centric patient relationships and agency-scoped data architecture

---

## 📖 **Table of Contents**

1. [Core Principles](#core-principles)
2. [Data Architecture](#data-architecture)
3. [Nurse Workflow Types](#nurse-workflow-types)
4. [Security & Compliance](#security--compliance)
5. [Implementation Patterns](#implementation-patterns)
6. [Testing Standards](#testing-standards)
7. [Migration Guide](#migration-guide)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 **Core Principles**

### **Principle 1: Shifts Control Patient Access**
Patient access is **always** mediated through shifts. No direct patient-nurse relationships exist in the system.

```dart
// ✅ CORRECT: Shift-mediated access
nurseShifts → assignedPatientIds → patients

// ❌ FORBIDDEN: Direct patient access  
patients.where('assignedNurses', arrayContains: nurseId)
```

### **Principle 2: Agency Boundaries Are Sacred**
Each agency operates as an isolated tenant. No cross-agency data access is permitted.

```dart
// ✅ CORRECT: Agency isolation
/agencies/metro_hospital/shifts/{id}    ← Metro data only
/agencies/sunrise_care/shifts/{id}      ← Sunrise data only
/independentShifts/{id}                 ← Independent data only

// ❌ FORBIDDEN: Cross-agency access
if (user.agencyId != patient.agencyId) { /* allow anyway */ }
```

### **Principle 3: Time-Bounded Access (HIPAA)**
Patient data access is tied to active work sessions. Off-duty = no patient access.

```dart
// ✅ CORRECT: Duty-aware access
if (!user.isOnDuty || currentShift == null) {
  return OffDutyView();
}

// ❌ FORBIDDEN: Always-on patient access
return PatientListView(); // Without duty check
```

### **Principle 4: Independent Nurse Support**
Independent nurses can create their own shifts and manage their own patients, completely separate from agency work.

```dart
// ✅ CORRECT: Independent nurse capabilities
- Create shifts with agencyId: null
- Manage nurse-owned patients (patient.agencyId: null)
- Dual-mode: Work for agencies AND independently
```

---

## 🏗️ **Data Architecture**

### **Firestore Collection Structure**

```
📁 /agencies/{agencyId}/
├── scheduledShifts/{shiftId}          ← Agency shift management
├── patients/{patientId}               ← Agency patient roster  
├── notes/{noteId}                     ← Agency patient notes
├── visits/{visitId}                   ← Agency visit tracking
└── analytics/{reportId}               ← Agency reporting data

📁 /independentShifts/{shiftId}        ← Independent nurse shifts

📁 /users/{userId}/
├── profile                            ← Professional information
├── ownedPatients/{patientId}          ← Independent nurse patients
├── independentNotes/{noteId}          ← Independent patient notes
└── workHistory/{sessionId}            ← Work session tracking

📁 /gamificationProfiles/{userId}      ← XP, badges (separated from professional data)
```

### **Shift Model Architecture**

```dart
@freezed
abstract class ScheduledShiftModel with _$ScheduledShiftModel {
  const factory ScheduledShiftModel({
    required String id,
    required String assignedTo,
    required DateTime startTime,
    required DateTime endTime,
    required String status,
    required bool isConfirmed,
    
    // 🏢 Agency Scoping
    String? agencyId,                    // null = independent shift
    
    // 👩‍⚕️ Independent Nurse Support  
    @Default(false) bool isUserCreated,  // true = nurse created
    String? createdBy,                   // audit trail
    
    // 👥 Patient Relationships (Core)
    List<String>? assignedPatientIds,    // THE patient relationship
    
    // 📍 Location & Context
    required String locationType,
    String? facilityName,
    String? address,
    
    // 📊 Metadata
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _ScheduledShiftModel;
}
```

### **Patient Model (Updated)**

```dart
@freezed
abstract class Patient with _$Patient {
  const factory Patient({
    required String id,
    required String firstName,
    required String lastName,
    required String location,
    
    // 🏢 Agency Scoping (Critical)
    String? agencyId,                    // null = independent patient
    String? ownerUid,                    // independent nurse who owns patient
    
    // ❌ REMOVED: Direct nurse assignments
    // List<String>? assignedNurses,     // FORBIDDEN FIELD
    
    // ... all other patient fields remain the same
  }) = _Patient;
}
```

---

## 👩‍⚕️ **Nurse Workflow Types**

### **Type 1: Agency-Only Nurse**

```dart
UserModel(
  isIndependentNurse: false,
  agencyRoles: {'metro_hospital': AgencyRole(...)},
  activeAgencyId: 'metro_hospital',
)
```

**Capabilities:**
- ✅ View available Metro Hospital shifts
- ✅ Request Metro Hospital shifts  
- ✅ Work assigned shifts with agency patients
- ❌ Cannot create own shifts
- ❌ Cannot manage independent patients

**Daily Workflow:**
1. Check available agency shifts
2. Request shifts or work assigned shifts
3. Access patients only during shift hours
4. Complete shift-based tasks and documentation

### **Type 2: Independent-Only Nurse**

```dart
UserModel(
  isIndependentNurse: true,
  agencyRoles: {},
  businessName: 'Smith Nursing Services',
)
```

**Capabilities:**
- ✅ Create independent shifts (agencyId: null)
- ✅ Manage own patient roster
- ✅ Set own schedule and rates
- ✅ Independent business reporting
- ❌ Cannot access agency shifts or patients

**Daily Workflow:**
1. Create shifts for patient care
2. Manage own patient roster
3. Schedule patient visits and care
4. Independent business management

### **Type 3: Dual-Mode Nurse (Recommended)**

```dart
UserModel(
  isIndependentNurse: true,
  agencyRoles: {
    'metro_hospital': AgencyRole(...),
    'sunrise_care': AgencyRole(...),
  },
  businessName: 'Dual Practice Nursing',
)
```

**Capabilities:**
- ✅ Request/work agency shifts from affiliated agencies
- ✅ Create independent shifts for own practice
- ✅ Context switching between agency and independent work
- ✅ Manage both agency and independent patient rosters
- ✅ Maximum workflow flexibility

**Daily Workflow Example:**
```
Tuesday Schedule:
8am-4pm:   Metro Hospital Shift (agency patients)
6pm-10pm:  Sunrise Care Shift (agency patients)  
11pm-7am:  Independent Shift (own patients)
```

---

## 🔒 **Security & Compliance**

### **HIPAA Compliance Features**

#### **Time-Bounded Access**
```dart
// Patient access only during active shifts
if (currentShift == null || !currentShift.isActive) {
  return NoPatientAccessView();
}
```

#### **Audit Trail Requirements**
```dart
// All patient access must be logged with shift context
AuditLog.record(
  userId: nurseId,
  action: 'patient_viewed',
  patientId: patientId,
  shiftId: currentShift.id,
  agencyId: currentShift.agencyId,
  timestamp: DateTime.now(),
);
```

#### **Data Isolation**
```dart
// Agency admins can only see their own data
if (admin.agencyId != shift.agencyId) {
  throw UnauthorizedAccessException();
}
```

### **Firestore Security Rules**

```javascript
// Agency shift access
match /agencies/{agencyId}/scheduledShifts/{shiftId} {
  allow read, write: if (
    // User is agency admin OR assigned nurse
    userIsAgencyAdmin(agencyId) || 
    resource.data.assignedTo == request.auth.uid
  );
}

// Independent shift access
match /independentShifts/{shiftId} {
  allow read, write: if resource.data.createdBy == request.auth.uid;
}

// Agency patient access
match /agencies/{agencyId}/patients/{patientId} {
  allow read: if (
    userIsAgencyAdmin(agencyId) ||
    userHasActiveShiftWithPatient(agencyId, patientId)
  );
}

// Independent patient access
match /users/{userId}/ownedPatients/{patientId} {
  allow read, write: if request.auth.uid == userId;
}
```

---

## 🛠️ **Implementation Patterns**

### **Repository Pattern: Shift-Centric Patient Access**

```dart
class FirebasePatientRepository implements AbstractPatientRepository {
  @override
  Future<List<Patient>> getShiftPatients(String shiftId) async {
    // Get shift to determine agency context
    final shift = await _shiftRepo.getById(shiftId);
    if (shift == null) return [];
    
    // Get patients assigned to this shift
    final patientIds = shift.assignedPatientIds ?? [];
    if (patientIds.isEmpty) return [];
    
    // Query patients from appropriate collection
    if (shift.agencyId != null) {
      // Agency patients
      return await _getAgencyPatients(shift.agencyId!, patientIds);
    } else {
      // Independent patients
      return await _getIndependentPatients(shift.createdBy!, patientIds);
    }
  }
  
  @override
  Future<void> assignPatientToShift(String patientId, String shiftId) async {
    final patient = await getById(patientId);
    final shift = await _shiftRepo.getById(shiftId);
    
    // Enforce agency boundaries
    if (patient.agencyId != shift.agencyId) {
      throw AgencyBoundaryViolation(
        'Cannot assign patient from agency ${patient.agencyId} '
        'to shift in agency ${shift.agencyId}'
      );
    }
    
    // Update shift with patient assignment
    await _shiftRepo.addPatientToShift(shiftId, patientId);
  }
}
```

### **State Management Pattern: Context-Aware Providers**

```dart
// Current shift provider (duty status aware)
@riverpod
Future<ScheduledShiftModel?> currentShift(CurrentShiftRef ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null || !user.isOnDuty) return null;
  
  final shifts = await ref.watch(userShiftsProvider(user.uid).future);
  return shifts.firstWhereOrNull((s) => s.isActive);
}

// Shift patients provider (auto-updates when shift changes)
@riverpod
Future<List<Patient>> currentShiftPatients(CurrentShiftPatientsRef ref) async {
  final currentShift = await ref.watch(currentShiftProvider.future);
  if (currentShift == null) return [];
  
  final repo = ref.watch(patientRepositoryProvider);
  return await repo.getShiftPatients(currentShift.id);
}

// Agency context provider (for dual-mode nurses)
@riverpod
String? activeAgencyContext(ActiveAgencyContextRef ref) {
  final user = ref.watch(authControllerProvider).value;
  return user?.activeAgencyId;
}
```

### **UI Pattern: Duty Status Enforcement**

```dart
class PatientListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentShift = ref.watch(currentShiftProvider);
    
    return currentShift.when(
      data: (shift) {
        if (shift == null) {
          // No active shift = no patient access
          return OffDutyView(
            title: 'Clock In Required',
            message: 'Start a shift to access patient information',
            action: ClockInButton(),
          );
        }
        
        // Active shift = show shift patients
        final patients = ref.watch(currentShiftPatientsProvider);
        return ShiftPatientListView(
          shift: shift,
          patients: patients,
        );
      },
      loading: () => LoadingView(),
      error: (error, stack) => ErrorView(error),
    );
  }
}
```

### **Service Pattern: Agency Boundary Enforcement**

```dart
class ShiftManagementService {
  Future<ScheduledShiftModel> createShift({
    required String nurseId,
    required DateTime startTime,
    required DateTime endTime,
    String? agencyId,
    List<String>? patientIds,
  }) async {
    // Validate nurse permissions
    final user = await _userRepo.getById(nurseId);
    
    if (agencyId != null) {
      // Agency shift - verify nurse has access
      if (!user.hasAccessToAgency(agencyId)) {
        throw UnauthorizedAgencyAccess('Nurse not affiliated with agency $agencyId');
      }
    } else {
      // Independent shift - verify nurse is independent
      if (!user.isIndependentNurse) {
        throw IndependentNurseRequired('Only independent nurses can create independent shifts');
      }
    }
    
    // Validate patient assignments if provided
    if (patientIds?.isNotEmpty == true) {
      await _validatePatientAssignments(patientIds!, agencyId);
    }
    
    // Create shift in appropriate collection
    final shift = ScheduledShiftModel(
      id: generateId(),
      assignedTo: nurseId,
      startTime: startTime,
      endTime: endTime,
      agencyId: agencyId,
      isUserCreated: true,
      createdBy: nurseId,
      assignedPatientIds: patientIds ?? [],
      status: 'scheduled',
      isConfirmed: false,
      locationType: 'facility', // Default, can be customized
      createdAt: DateTime.now(),
    );
    
    if (agencyId != null) {
      await _shiftConverters.createShift(agencyId, shift);
    } else {
      await _shiftConverters.createIndependentShift(shift);
    }
    
    return shift;
  }
  
  Future<void> _validatePatientAssignments(List<String> patientIds, String? agencyId) async {
    for (final patientId in patientIds) {
      final patient = await _patientRepo.getById(patientId);
      
      // Enforce agency boundaries
      if (patient.agencyId != agencyId) {
        throw AgencyBoundaryViolation(
          'Patient $patientId belongs to agency ${patient.agencyId}, '
          'cannot assign to ${agencyId ?? 'independent'} shift'
        );
      }
    }
  }
}
```

---

## 🧪 **Testing Standards**

### **Required Test Categories**

#### **1. Shift-Centric Access Tests**
```dart
group('Shift-Centric Patient Access', () {
  test('returns patients only from active shifts', () async {
    // Setup
    final nurse = MockUser(id: 'nurse1');
    final activeShift = MockShift(assignedTo: 'nurse1', patientIds: ['pat1', 'pat2']);
    final inactiveShift = MockShift(assignedTo: 'nurse1', patientIds: ['pat3'], isActive: false);
    
    // Test
    final patients = await repo.getCurrentShiftPatients('nurse1');
    
    // Assert
    expect(patients.map((p) => p.id), equals(['pat1', 'pat2']));
    expect(patients.map((p) => p.id), isNot(contains('pat3')));
  });
  
  test('returns empty list when nurse is off duty', () async {
    // Setup
    final nurse = MockUser(id: 'nurse1', isOnDuty: false);
    
    // Test
    final patients = await repo.getCurrentShiftPatients('nurse1');
    
    // Assert
    expect(patients, isEmpty);
  });
});
```

#### **2. Agency Boundary Tests**
```dart
group('Agency Boundary Enforcement', () {
  test('prevents cross-agency patient assignment', () async {
    // Setup
    final metroPatient = MockPatient(id: 'pat1', agencyId: 'metro_hospital');
    final sunriseShift = MockShift(id: 'shift1', agencyId: 'sunrise_care');
    
    // Test & Assert
    expect(
      () => service.assignPatientToShift('pat1', 'shift1'),
      throwsA(isA<AgencyBoundaryViolation>()),
    );
  });
  
  test('allows same-agency patient assignment', () async {
    // Setup
    final metroPatient = MockPatient(id: 'pat1', agencyId: 'metro_hospital');
    final metroShift = MockShift(id: 'shift1', agencyId: 'metro_hospital');
    
    // Test
    await service.assignPatientToShift('pat1', 'shift1');
    
    // Assert
    final shift = await repo.getShiftById('shift1');
    expect(shift.assignedPatientIds, contains('pat1'));
  });
});
```

#### **3. Independent Nurse Tests**
```dart
group('Independent Nurse Workflows', () {
  test('allows independent nurse to create independent shifts', () async {
    // Setup
    final independentNurse = MockUser(
      id: 'nurse1', 
      isIndependentNurse: true,
      businessName: 'Smith Nursing',
    );
    
    // Test
    final shift = await service.createIndependentShift(
      nurseId: 'nurse1',
      startTime: DateTime.now().add(Duration(hours: 1)),
      endTime: DateTime.now().add(Duration(hours: 9)),
    );
    
    // Assert
    expect(shift.agencyId, isNull);
    expect(shift.isUserCreated, isTrue);
    expect(shift.createdBy, equals('nurse1'));
  });
  
  test('prevents agency-only nurse from creating independent shifts', () async {
    // Setup
    final agencyNurse = MockUser(
      id: 'nurse1', 
      isIndependentNurse: false,
      agencyRoles: {'metro_hospital': MockAgencyRole()},
    );
    
    // Test & Assert
    expect(
      () => service.createIndependentShift(nurseId: 'nurse1'),
      throwsA(isA<IndependentNurseRequired>()),
    );
  });
});
```

#### **4. Dual-Mode Nurse Tests**
```dart
group('Dual-Mode Nurse Workflows', () {
  test('supports context switching between agency and independent work', () async {
    // Setup
    final dualModeNurse = MockUser(
      id: 'nurse1',
      isIndependentNurse: true,
      agencyRoles: {'metro_hospital': MockAgencyRole()},
      activeAgencyId: 'metro_hospital',
    );
    
    // Test agency context
    await service.switchToAgencyContext('nurse1', 'metro_hospital');
    final agencyPatients = await repo.getContextPatients('nurse1');
    
    // Test independent context  
    await service.switchToIndependentContext('nurse1');
    final independentPatients = await repo.getContextPatients('nurse1');
    
    // Assert
    expect(agencyPatients.every((p) => p.agencyId == 'metro_hospital'), isTrue);
    expect(independentPatients.every((p) => p.agencyId == null), isTrue);
  });
});
```

### **Mock Data Patterns**

```dart
class ShiftTestingMocks {
  static ScheduledShiftModel agencyShift({
    String? id,
    String? agencyId,
    String? assignedTo,
    List<String>? patientIds,
  }) {
    return ScheduledShiftModel(
      id: id ?? generateId(),
      agencyId: agencyId ?? 'metro_hospital',
      assignedTo: assignedTo ?? 'nurse1',
      isUserCreated: false,
      createdBy: 'admin1',
      assignedPatientIds: patientIds ?? ['pat1', 'pat2'],
      status: 'scheduled',
      isConfirmed: true,
      startTime: DateTime.now().add(Duration(hours: 1)),
      endTime: DateTime.now().add(Duration(hours: 9)),
      locationType: 'facility',
      facilityName: 'Metro General Hospital',
    );
  }
  
  static ScheduledShiftModel independentShift({
    String? id,
    String? assignedTo,
    List<String>? patientIds,
  }) {
    return ScheduledShiftModel(
      id: id ?? generateId(),
      agencyId: null,
      assignedTo: assignedTo ?? 'nurse1',
      isUserCreated: true,
      createdBy: assignedTo ?? 'nurse1',
      assignedPatientIds: patientIds ?? ['pat_ind_1'],
      status: 'scheduled',
      isConfirmed: true,
      startTime: DateTime.now().add(Duration(hours: 1)),
      endTime: DateTime.now().add(Duration(hours: 9)),
      locationType: 'residence',
      address: '123 Main St, Independent Care',
    );
  }
  
  static Patient agencyPatient({
    String? id,
    String? agencyId,
  }) {
    return Patient(
      id: id ?? generateId(),
      firstName: 'John',
      lastName: 'Doe',
      location: 'facility',
      agencyId: agencyId ?? 'metro_hospital',
      department: 'ICU',
      roomNumber: '201A',
    );
  }
  
  static Patient independentPatient({
    String? id,
    String? ownerUid,
  }) {
    return Patient(
      id: id ?? generateId(),
      firstName: 'Jane',
      lastName: 'Smith',
      location: 'residence',
      agencyId: null,
      ownerUid: ownerUid ?? 'nurse1',
      addressLine1: '456 Oak Street',
      city: 'Independent City',
    );
  }
}
```

---

## 📋 **Migration Guide**

### **Phase 1: Model Updates (Completed)**
- [x] Extended ScheduledShiftModel with agency scoping fields
- [x] Updated UserModel with independent nurse support
- [x] Created agency-scoped Firestore converters
- [x] Added extension methods for shift ownership logic

### **Phase 2: Repository Migration**

#### **Before: Direct Patient-Nurse Relationships**
```dart
// ❌ OLD: Direct patient queries
class OldPatientRepository {
  Future<List<Patient>> getAssignedPatients(String nurseId) async {
    return await firestore
        .collection('patients')
        .where('assignedNurses', arrayContains: nurseId)
        .get();
  }
}
```

#### **After: Shift-Centric Patient Access**
```dart
// ✅ NEW: Shift-mediated patient queries
class NewPatientRepository {
  Future<List<Patient>> getCurrentShiftPatients(String nurseId) async {
    // Step 1: Get nurse's active shifts
    final shifts = await shiftRepo.getActiveShifts(nurseId);
    
    // Step 2: Collect all patient IDs from shifts
    final patientIds = shifts
        .expand((shift) => shift.assignedPatientIds ?? [])
        .toSet()
        .toList();
    
    // Step 3: Query patients by IDs from appropriate collections
    final patients = <Patient>[];
    for (final shift in shifts) {
      if (shift.agencyId != null) {
        // Agency patients
        patients.addAll(await getAgencyPatients(shift.agencyId!, patientIds));
      } else {
        // Independent patients
        patients.addAll(await getIndependentPatients(shift.createdBy!, patientIds));
      }
    }
    
    return patients;
  }
}
```

### **Phase 3: Data Migration Scripts**

#### **Migration Script: Patient Assignments to Shifts**
```dart
class PatientAssignmentMigration {
  Future<void> migratePatientAssignments() async {
    // Step 1: Backup existing data
    await backupCollection('patients');
    await backupCollection('scheduledShifts');
    
    // Step 2: Process each patient
    final patients = await firestore.collection('patients').get();
    
    for (final patientDoc in patients.docs) {
      final patient = Patient.fromJson(patientDoc.data());
      final assignedNurses = patient.assignedNurses ?? [];
      
      for (final nurseId in assignedNurses) {
        // Find or create appropriate shift for this nurse-patient relationship
        await migratePatientToShift(patient.id, nurseId, patient.agencyId);
      }
    }
    
    // Step 3: Remove deprecated assignedNurses field
    await removeDeprecatedFields();
    
    // Step 4: Validate data integrity
    await validateMigration();
  }
  
  Future<void> migratePatientToShift(String patientId, String nurseId, String? agencyId) async {
    // Find existing shift or create new one
    final existingShift = await findExistingShift(nurseId, agencyId);
    
    if (existingShift != null) {
      // Add patient to existing shift
      await addPatientToShift(existingShift.id, patientId);
    } else {
      // Create new shift for this relationship
      final newShift = ScheduledShiftModel(
        id: generateId(),
        assignedTo: nurseId,
        agencyId: agencyId,
        isUserCreated: false, // Migrated from old system
        createdBy: 'migration_script',
        assignedPatientIds: [patientId],
        status: 'scheduled',
        isConfirmed: true,
        startTime: DateTime.now(), // Default to now, can be updated later
        endTime: DateTime.now().add(Duration(hours: 8)),
        locationType: 'facility',
      );
      
      if (agencyId != null) {
        await ScheduledShiftModelConverters.createShift(agencyId, newShift);
      } else {
        await ScheduledShiftModelConverters.createIndependentShift(newShift);
      }
    }
  }
}
```

### **Phase 4: UI Migration**

#### **Update Patient List Screen**
```dart
// ❌ OLD: Direct patient loading
class OldPatientListScreen extends ConsumerWidget {
  Widget build(context, ref) {
    final patients = ref.watch(assignedPatientsProvider);
    return PatientListView(patients: patients);
  }
}

// ✅ NEW: Shift-aware patient loading
class NewPatientListScreen extends ConsumerWidget {
  Widget build(context, ref) {
    final currentShift = ref.watch(currentShiftProvider);
    
    return currentShift.when(
      data: (shift) {
        if (shift == null) {
          return OffDutyView();
        }
        
        final patients = ref.watch(shiftPatientsProvider(shift.id));
        return ShiftAwarePatientListView(
          shift: shift,
          patients: patients,
        );
      },
      loading: () => LoadingView(),
      error: (error, stack) => ErrorView(error),
    );
  }
}
```

---

## 🔧 **Troubleshooting**

### **Common Issues & Solutions**

#### **Issue 1: "No patients showing for nurse"**
```
Symptoms: Nurse is on duty but patient list is empty
Diagnosis: Check shift-patient relationships

Solution:
1. Verify nurse has active shift: currentShiftProvider
2. Check shift has assigned patients: shift.assignedPatientIds
3. Validate patient queries are shift-scoped
4. Ensure agency boundaries are respected
```

#### **Issue 2: "Cross-agency data access error"**
```
Symptoms: AgencyBoundaryViolation exceptions
Diagnosis: Patient-shift agency mismatch

Solution:
1. Validate patient.agencyId == shift.agencyId
2. Check independent patient (agencyId: null) assignment rules
3. Verify user agency permissions
4. Ensure context switching works properly
```

#### **Issue 3: "Independent nurse cannot create shifts"**
```
Symptoms: IndependentNurseRequired exceptions
Diagnosis: User permissions or flag issues

Solution:
1. Check user.isIndependentNurse == true
2. Verify agencyId is null for independent shifts
3. Validate shift creation permissions
4. Check feature flag settings
```

#### **Issue 4: "Patient access when off duty"**
```
Symptoms: HIPAA violation warnings
Diagnosis: Duty status not enforced

Solution:
1. Add currentShiftProvider checks to all patient screens
2. Implement OffDutyView for null shift states
3. Validate user.isOnDuty status
4. Ensure shift timing is respected
```

### **Debug Helpers**

```dart
class ShiftDebugHelper {
  static void logShiftContext(String nurseId) {
    print('=== SHIFT CONTEXT DEBUG ===');
    print('Nurse ID: $nurseId');
    
    final user = getCurrentUser(nurseId);
    print('Is Independent: ${user?.isIndependentNurse}');
    print('Agency Roles: ${user?.agencyRoles.keys}');
    print('Active Agency: ${user?.activeAgencyId}');
    
    final shifts = getCurrentShifts(nurseId);
    print('Active Shifts: ${shifts.length}');
    
    for (final shift in shifts) {
      print('  Shift ${shift.id}:');
      print('    Agency: ${shift.agencyId ?? 'Independent'}');
      print('    Patients: ${shift.assignedPatientIds?.length ?? 0}');
      print('    User Created: ${shift.isUserCreated}');
    }
  }
  
  static void validateAgencyBoundaries(String shiftId, List<String> patientIds) {
    final shift = getShiftById(shiftId);
    print('=== AGENCY BOUNDARY VALIDATION ===');
    print('Shift Agency: ${shift.agencyId}');
    
    for (final patientId in patientIds) {
      final patient = getPatientById(patientId);
      final isValid = patient.agencyId == shift.agencyId;
      print('Patient $patientId: ${patient.agencyId} -> ${isValid ? "✅" : "❌"}');
    }
  }
}
```

---

## 📚 **Additional Resources**

### **Related Documentation**
- [NurseOS_v2_ARCHITECTURE.md](./NurseOS_v2_ARCHITECTURE.md) - Overall architecture
- [NurseOS_Feature_Dev_Guide_v2-2.md](./NurseOS_Feature_Dev_Guide_v2-2.md) - Development patterns
- [HIPAA_Readiness_Checklist.md](./HIPAA_Readiness_Checklist.md) - Compliance requirements

### **Code Examples**
- [ScheduledShiftModel](../lib/features/schedule/models/scheduled_shift_model.dart)
- [ScheduledShiftModelConverters](../lib/features/schedule/models/scheduled_shift_model_converters.dart)
- [UserModel Extensions](../lib/features/auth/models/user_model_extensions.dart)

### **Implementation Checklist**

#### **For New Features**
- [ ] Does this feature respect shift-centric patient access?
- [ ] Are agency boundaries properly enforced?
- [ ] Is duty status checked before patient data access?
- [ ] Does this work for independent nurses?
- [ ] Are audit trails properly maintained?

#### **For UI Components**
- [ ] Shows appropriate off-duty state when no active shift
- [ ] Displays shift context clearly to user
- [ ] Handles agency context switching (for dual-mode nurses)
- [ ] Provides clear ownership indicators for shifts

#### **For Data Operations**
- [ ] All patient queries go through shift context
- [ ] Agency boundary validation is in place
- [ ] Independent nurse workflows are supported
- [ ] Proper error handling for boundary violations

---

This comprehensive reference guide ensures all developers understand and implement the shift-centric architecture correctly, maintaining data integrity, security, and user experience across all nursing workflows.