# NurseOS Shift-Centric Architecture Reference

> **Version**: 2.1  
> **Date**: July 11, 2025  
> **Context**: Migration from patient-centric to shift-centric patient assignments

---

## 🎯 **Core Principle**

**Patients are ONLY assigned to nurses through shifts.** This creates a single source of truth for all patient-nurse relationships and supports both agency and independent nursing practice.

---

## 🏗️ **Data Model Changes**

### **BEFORE: Patient-Centric (Deprecated)**
```dart
// ❌ OLD MODEL - Being removed
Patient {
  id: string,
  firstName: string,
  lastName: string,
  assignedNurses: [nurseId1, nurseId2], // ← REMOVING THIS
  // ... other fields
}

// Query patients by nurse
patients.where('assignedNurses', arrayContains: nurseId)
```

### **AFTER: Shift-Centric (New Standard)**
```dart
// ✅ NEW MODEL - Single source of truth
Patient {
  id: string,
  firstName: string,
  lastName: string,
  // NO assignedNurses field
  // ... other fields
}

ScheduledShift {
  id: string,
  assignedTo: nurseId,
  assignedPatientIds: [patient1, patient2, patient3], // ← Truth lives here
  shiftType: ShiftType,
  agencyId?: string, // null for independent practice
  // ... other fields
}

// Query patients by finding nurse's shifts first
1. Get shifts: shifts.where('assignedTo', isEqualTo: nurseId)
2. Collect all assignedPatientIds
3. Query patients: patients.where('id', whereIn: patientIds)
```

---

## 🔄 **Shift Types & Use Cases**

### **Agency Nurses**
```dart
enum AgencyShiftType {
  facility,    // Hospital, SNF, assisted living
  home_care,   // Agency-scheduled home visits
  emergency,   // Urgent coverage requests
}

// Example: ICU shift
ScheduledShift {
  assignedTo: 'nurse_sarah_123',
  assignedPatientIds: ['patient_001', 'patient_002', 'patient_003'],
  shiftType: 'facility',
  agencyId: 'mercy_hospital',
  facilityName: 'Mercy General Hospital',
  department: 'ICU',
  startTime: '2025-07-12T07:00:00Z',
  endTime: '2025-07-12T19:00:00Z'
}
```

### **Independent Nurses**
```dart
enum IndependentShiftType {
  private_duty,  // 1:1 patient care
  caseload,      // Ongoing patient management
  recurring,     // Regular scheduled visits
  consultation,  // One-time assessments
}

// Example: Private duty nurse
ScheduledShift {
  assignedTo: 'nurse_mike_456',
  assignedPatientIds: ['patient_mrs_johnson'],
  shiftType: 'private_duty',
  agencyId: null, // Independent practice
  startTime: '2025-07-12T08:00:00Z',
  endTime: '2025-07-12T16:00:00Z',
  recurringPattern: 'weekly_tuesday'
}
```

---

## 📊 **Repository Implementation**

### **Patient Repository Pattern**
```dart
class FirebasePatientRepository implements PatientRepository {
  
  @override
  Future<Either<Failure, List<Patient>>> getAllPatients(String nurseId) async {
    try {
      // Step 1: Get nurse's shifts
      final shiftsQuery = _firestore
          .collectionGroup('scheduledShifts')
          .where('assignedTo', isEqualTo: nurseId);
      
      final shiftsSnapshot = await shiftsQuery.get();
      
      // Step 2: Collect all patient IDs from shifts
      final patientIds = <String>{};
      for (final shiftDoc in shiftsSnapshot.docs) {
        final shift = ScheduledShiftModel.fromJson(shiftDoc.data());
        patientIds.addAll(shift.assignedPatientIds ?? []);
      }
      
      if (patientIds.isEmpty) {
        return const Right([]);
      }
      
      // Step 3: Query patients by collected IDs
      final patientsQuery = _firestore
          .collectionGroup('patients')
          .where(FieldPath.documentId, whereIn: patientIds.toList());
      
      final patientsSnapshot = await patientsQuery.get();
      final patients = patientsSnapshot.docs
          .map((doc) => Patient.fromJson(doc.data()))
          .toList();
      
      return Right(patients);
    } catch (e) {
      return Left(Failure.unexpected('Failed to fetch patients: $e'));
    }
  }
}
```

### **Optimized Stream Query**
```dart
@override
Stream<Either<Failure, List<Patient>>> watchAllPatients(String nurseId) {
  return _firestore
      .collectionGroup('scheduledShifts')
      .where('assignedTo', isEqualTo: nurseId)
      .snapshots()
      .asyncMap((shiftsSnapshot) async {
        try {
          // Collect patient IDs from current shifts
          final patientIds = <String>{};
          for (final doc in shiftsSnapshot.docs) {
            final shift = ScheduledShiftModel.fromJson(doc.data());
            patientIds.addAll(shift.assignedPatientIds ?? []);
          }
          
          if (patientIds.isEmpty) {
            return const Right(<Patient>[]);
          }
          
          // Query patients
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
```

---

## 🔧 **Migration Strategy**

### **Phase 1: Data Migration**
1. **Backup existing data** with `assignedNurses` fields
2. **Create shifts for existing patient assignments**:
   ```dart
   // For each patient with assignedNurses
   for (patient in patients) {
     for (nurseId in patient.assignedNurses) {
       // Create ongoing caseload shift
       createScheduledShift({
         assignedTo: nurseId,
         assignedPatientIds: [patient.id],
         shiftType: 'caseload',
         agencyId: inferAgencyFromNurse(nurseId),
         isOngoing: true
       });
     }
   }
   ```

### **Phase 2: Code Migration**
1. **Update Patient model** - Remove `assignedNurses` field
2. **Update PatientRepository** - Implement shift-based queries
3. **Update all patient queries** throughout the app
4. **Add shift management UI** for independent nurses

### **Phase 3: Validation**
1. **Verify all patients** still appear for correct nurses
2. **Test independent nurse** shift creation workflows
3. **Performance testing** of multi-step queries

---

## 🚀 **New Features Enabled**

### **Independent Nurse Workflows**
```dart
// Create ongoing caseload shift
await shiftService.createCaseloadShift(
  nurseId: currentUser.uid,
  patientIds: [selectedPatient.id],
  recurringPattern: 'weekly_monday_wednesday'
);

// Schedule specific visit
await shiftService.createVisitShift(
  nurseId: currentUser.uid,
  patientId: patient.id,
  startTime: DateTime(2025, 7, 15, 10, 0),
  duration: Duration(hours: 2)
);
```

### **Agency Admin Features**
```dart
// Bulk assign facility patients to shift
await adminService.assignFacilityShift(
  shiftId: facilityShift.id,
  facilityName: 'Mercy General ICU',
  department: 'ICU',
  // Automatically assigns all ICU patients
);

// Emergency coverage with patient handoff
await adminService.createEmergencyShift(
  originalShiftId: 'sick_nurse_shift',
  coverageNurseId: 'backup_nurse_123',
  // Transfers all patients from original shift
);
```

---

## ⚡ **Performance Considerations**

### **Query Optimization**
- **Collection Group Queries**: Use for cross-agency patient access
- **Firestore Indexes**: Required for `assignedTo + agencyId` combinations
- **Caching Strategy**: Cache nurse's patient list with shift invalidation
- **Pagination**: For nurses with large patient caseloads

### **Firestore Indexes Required**
```
Collection Group: scheduledShifts
Fields: assignedTo (Ascending), agencyId (Ascending), startTime (Ascending)

Collection Group: patients  
Fields: agencyId (Ascending), location (Ascending), department (Ascending)
```

---

## 🔒 **HIPAA & Security**

### **Benefits of Shift-Centric Model**
- **Clear Audit Trail**: Every patient access tied to specific shift
- **Time-Bounded Access**: Patients only accessible during shift periods
- **Automatic Deprovisioning**: Patient access ends when shift ends
- **Agency Isolation**: Cross-agency data leakage prevented

### **Access Control Rules**
```dart
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

## 🧪 **Testing Strategy**

### **Unit Tests**
- **Repository Logic**: Multi-step patient queries
- **Shift Creation**: Independent nurse workflows  
- **Patient Assignment**: Agency admin bulk assignment

### **Integration Tests**
- **Cross-Agency Isolation**: Verify no data leakage
- **Performance**: Large caseload query timing
- **Real-time Updates**: Shift changes update patient lists

### **Migration Tests**
- **Data Integrity**: All patients still accessible post-migration
- **Backward Compatibility**: Existing workflows continue working
- **Rollback Capability**: Ability to revert if issues found

---

## 🎯 **Success Metrics**

### **Functional**
- ✅ All existing patients remain accessible to correct nurses
- ✅ Independent nurses can create and manage their own shifts
- ✅ Agency admins can bulk-assign facility patients
- ✅ No cross-agency data access violations

### **Performance**
- ✅ Patient list loads in <2 seconds for caseloads up to 50 patients
- ✅ Real-time shift updates propagate to patient list within 1 second
- ✅ Query costs remain under current Firestore budget

### **User Experience**
- ✅ No disruption to existing nurse workflows
- ✅ Intuitive shift creation for independent nurses
- ✅ Clear patient assignment status in UI

---

## 📚 **Implementation Checklist**

### **Backend Changes**
- [ ] Remove `assignedNurses` field from Patient model
- [ ] Update Patient repository to shift-based queries
- [ ] Create shift management service
- [ ] Add Firestore indexes for new query patterns
- [ ] Update security rules for shift-based access

### **Frontend Changes**  
- [ ] Add "Create Shift" UI for independent nurses
- [ ] Update patient list to show shift context
- [ ] Add shift management screens
- [ ] Update admin portal for bulk patient assignment
- [ ] Add shift-patient relationship indicators

### **Migration**
- [ ] Create data migration script
- [ ] Test migration on staging environment  
- [ ] Plan rollback strategy
- [ ] Schedule production migration window
- [ ] Monitor post-migration performance

---

**This shift-centric architecture provides a unified, scalable foundation for both agency and independent nursing practice while maintaining HIPAA compliance and optimal performance.**