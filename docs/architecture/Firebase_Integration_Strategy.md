# Firebase Integration Strategy – NurseOS v2

> All Firebase interactions are abstracted, tested, and compliant with HIPAA policies. No direct Firebase calls are allowed in UI layers. **Now featuring shift-centric patient relationships.**

---

## ✅ Core Principles

- 🔒 **HIPAA-Compliant Design**
  - All Firebase access is routed through secure repositories.
  - Use of Firestore, Authentication, and Functions reviewed under BAA.

- 🧱 **Layer Separation**
  - `data/` layer only: No Firebase code in `features/` or `shared/` layers.
  - Riverpod providers bridge repositories and feature logic.

- 🧪 **Test Coverage**
  - Every repository is backed by unit tests and mock implementations.
  - Use mock toggles (`useMock`) in all feature modules.

- ⭐ **Shift-Centric Relationships**
  - Patient-nurse relationships ONLY exist through scheduled shifts.
  - No direct `assignedNurses` fields in patient documents.

---

## 🔧 Authentication

- Uses **Firebase Authentication** (email/password, SSO optional)
- Custom claims injected via Firebase Admin SDK to enforce RBAC
- Reauth enforced for sensitive ops (e.g., data export, deletions)

---

## 🔥 Firestore Usage

### **Collection Architecture**

#### **Agency-Scoped Collections** (Multi-tenancy)
```
/agencies/{agencyId}/
  ├── patients/          ← NO assignedNurses field
  ├── shifts/            ← Available shifts for nurse requests
  ├── scheduledShifts/   ← Assigned shifts (defines patient relationships) ⭐
  └── workSessions/      ← Nurse shift history
```

#### **Global Collections**
```
/users/                  ← Nurse metadata, XP, roles, agency assignments
/leaderboards/          ← Gamification metrics (admin view only)
/auditLogs/             ← HIPAA compliance and access logs
```

### **Data Model Standards**

- Structured via `withConverter<T>()` for all models (no manual `.data()` or `.map()` calls)
- All documents include `createdAt`, `updatedAt`, `createdBy`, `modifiedBy`
- **Agency isolation**: All patient data scoped to agency collections

### **Shift-Centric Patient Queries** ⭐

#### **Repository Pattern**
```dart
class FirebasePatientRepository implements PatientRepository {
  @override
  Stream<Either<Failure, List<Patient>>> watchAllPatients(String nurseId) {
    // Step 1: Watch nurse's scheduled shifts
    return _firestore
        .collectionGroup('scheduledShifts')
        .where('assignedTo', isEqualTo: nurseId)
        .snapshots()
        .asyncMap((shiftsSnapshot) async {
          try {
            // Step 2: Collect patient IDs from all shifts
            final patientIds = <String>{};
            for (final shiftDoc in shiftsSnapshot.docs) {
              final shift = ScheduledShiftModel.fromJson(shiftDoc.data());
              patientIds.addAll(shift.assignedPatientIds ?? []);
            }
            
            if (patientIds.isEmpty) {
              return const Right(<Patient>[]);
            }
            
            // Step 3: Query patients by collected IDs
            final patientsSnapshot = await _firestore
                .collectionGroup('patients')
                .where(FieldPath.documentId, whereIn: patientIds.toList())
                .get();
            
            final patients = patientsSnapshot.docs
                .map((doc) => Patient.fromJson(doc.data()))
                .toList();
            
            return Right<Failure, List<Patient>>(patients);
          } catch (e) {
            return Left<Failure, List<Patient>>(
              Failure.unexpected('Failed to stream patients: $e')
            );
          }
        });
  }
}
```

#### **Query Optimization**
```dart
// Required Firestore Indexes
Collection Group: scheduledShifts
Fields: assignedTo (Ascending), agencyId (Ascending), startTime (Ascending)

Collection Group: patients
Fields: agencyId (Ascending), location (Ascending), department (Ascending)
```

---

## 🛠️ Firebase Functions

### **Shift-Related Cloud Functions**
- **`assignPatientsToShift`**: Bulk patient assignment for facility shifts
- **`transferShiftPatients`**: Emergency coverage patient handoff
- **`validateShiftAccess`**: HIPAA-compliant patient access verification
- **`auditPatientAccess`**: Log all patient data access via shifts

### **Existing Functions**
- All role-sensitive logic (e.g., `grantXp`, `softDeletePatient`) uses Cloud Functions
- Callable Functions return validated DTOs only
- No direct writes from client to protected collections

---

## 🧩 Integration Rules

### **Repository Patterns**

#### **Multi-Step Query Pattern** (New Standard)
```dart
// For patient queries via shifts
1. Query scheduledShifts where assignedTo == nurseId
2. Collect all assignedPatientIds from results
3. Query patients where documentId in [patientIds]
4. Return merged patient list
```

#### **Direct Query Pattern** (Traditional)
```dart
// For user profiles, shifts, etc.
users.where('uid', isEqualTo: userId).get()
```

### **Firebase Initialization**
- All Firebase init is done in `lib/core/firebase/`
- Firebase is initialized in a guarded way using:
  ```dart
  await guardFirebaseInitialization();
  ```
- No Firestore instances in UI or `Notifier` classes – use `RepositoryProvider`

---

## 🧪 Testing Firebase Code

### **Standard Tests**
- Use `FakeFirebaseFirestore` and `MockFirebaseAuth` in tests
- All repositories must test: CRUD behavior, Auth logic, Error handling and retries

### **Shift-Centric Testing** ⭐
```dart
group('Shift-Centric Patient Repository', () {
  test('should return patients from nurse shifts', () async {
    // Setup: Create scheduled shifts with patient assignments
    await fakeFirestore.collection('agencies/test_agency/scheduledShifts').add({
      'assignedTo': 'nurse123',
      'assignedPatientIds': ['patient1', 'patient2']
    });
    
    // Setup: Create patients
    await fakeFirestore.collection('agencies/test_agency/patients').doc('patient1').set({
      'firstName': 'John',
      'lastName': 'Doe'
    });
    
    // Test: Query patients via shifts
    final result = await repository.getAllPatients('nurse123');
    
    // Verify: Correct patients returned
    expect(result.isRight(), true);
    expect(result.getOrElse(() => []).length, equals(1));
  });
  
  test('should return empty list when nurse has no shifts', () async {
    final result = await repository.getAllPatients('nurse_no_shifts');
    
    expect(result.isRight(), true);
    expect(result.getOrElse(() => []), isEmpty);
  });
  
  test('should handle large patient caseloads efficiently', () async {
    // Performance test: 50+ patients across multiple shifts
    final stopwatch = Stopwatch()..start();
    final result = await repository.getAllPatients('nurse_large_caseload');
    stopwatch.stop();
    
    expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // < 2 seconds
  });
});
```

---

## 🔒 Security & HIPAA

### **Shift-Based Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  // Agency-scoped patient access via shifts
  match /agencies/{agencyId}/patients/{patientId} {
    allow read: if isNurseAssignedToPatientViaShift(agencyId, patientId);
    allow write: if isAuthenticatedNurse() && isNurseAssignedToPatientViaShift(agencyId, patientId);
  }
  
  // Scheduled shifts - nurses can read their own assignments
  match /agencies/{agencyId}/scheduledShifts/{shiftId} {
    allow read: if isAssignedToShift(shiftId);
    allow update: if isAssignedToShift(shiftId) && isConfirmationUpdate();
  }
  
  function isNurseAssignedToPatientViaShift(agencyId, patientId) {
    return exists(/databases/$(database)/documents/agencies/$(agencyId)/scheduledShifts/$(getUserActiveShift(request.auth.uid))) &&
           patientId in get(/databases/$(database)/documents/agencies/$(agencyId)/scheduledShifts/$(getUserActiveShift(request.auth.uid))).data.assignedPatientIds;
  }
  
  function isAssignedToShift(shiftId) {
    return request.auth != null && 
           get(/databases/$(database)/documents/scheduledShifts/$(shiftId)).data.assignedTo == request.auth.uid;
  }
}
```

### **Audit Trail Benefits**
- **Time-Bounded Access**: Patient access automatically expires when shift ends
- **Clear Relationship**: Every patient access tied to specific shift assignment
- **Agency Isolation**: Cross-agency data leakage prevented by shift scope
- **Automatic Logging**: All patient queries logged with shift context

---

## 🚀 Shift Management Integration

### **Admin Portal Functions**
```dart
// Bulk assign facility patients to approved shift
Future<void> assignFacilityPatientsToShift(String shiftId, String facilityName) async {
  final batch = _firestore.batch();
  
  // Find facility patients
  final patients = await _firestore
      .collectionGroup('patients')
      .where('location', isEqualTo: 'hospital')
      .where('facilityName', isEqualTo: facilityName)
      .get();
  
  // Update shift with patient assignments
  final shiftRef = _firestore.doc('agencies/test_agency/scheduledShifts/$shiftId');
  batch.update(shiftRef, {
    'assignedPatientIds': patients.docs.map((doc) => doc.id).toList()
  });
  
  await batch.commit();
}
```

### **Independent Nurse Functions**
```dart
// Create ongoing caseload shift
Future<void> createCaseloadShift(String nurseId, List<String> patientIds) async {
  await _firestore.collection('agencies/independent/scheduledShifts').add({
    'assignedTo': nurseId,
    'assignedPatientIds': patientIds,
    'shiftType': 'caseload',
    'agencyId': null, // Independent practice
    'isOngoing': true,
    'createdAt': FieldValue.serverTimestamp()
  });
}
```

---

## 📊 Performance Monitoring

### **Query Performance Targets**
- **Patient List Load**: < 2 seconds for caseloads up to 50 patients
- **Real-time Updates**: Shift changes propagate to patient list within 1 second
- **Firestore Costs**: Maintain current read budget despite multi-step queries

### **Optimization Strategies**
- **Collection Group Queries**: Leverage for cross-agency access patterns
- **Strategic Indexing**: Optimize for `assignedTo + agencyId + startTime` combinations
- **Caching Layer**: Cache patient lists with shift-based invalidation
- **Pagination**: Support large caseloads without performance degradation

---

## 🎯 Migration & Rollback

### **Data Migration Process**
1. **Backup Phase**: Export all existing patient `assignedNurses` relationships
2. **Shift Creation**: Generate scheduled shifts for existing patient assignments
3. **Validation Phase**: Verify all patients remain accessible via new shift model
4. **Cleanup Phase**: Remove `assignedNurses` fields from patient documents

### **Rollback Strategy**
- Preserved backup of original patient-nurse relationships
- Ability to restore `assignedNurses` fields if critical issues detected
- Monitoring dashboard for post-migration performance and access patterns

---

**This shift-centric Firebase integration strategy provides a more secure, scalable, and HIPAA-compliant foundation for patient-nurse relationships while supporting both agency and independent nursing workflows.**