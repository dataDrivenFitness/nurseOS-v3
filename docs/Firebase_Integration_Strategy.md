> ⚠️ UPDATE NOTE: This document has been synced to NurseOS v2 architecture.
> UPDATED: Synced collection naming and `useMockServices` guidance with v2 blueprint. Revalidated firestore converter logic.

...

# 🔥 NurseOS Firebase Integration Strategy (June 2025)

This document outlines the integration strategy for connecting NurseOS to Firebase Firestore and Firebase Auth while maintaining modularity, HIPAA readiness, and offline mock compatibility.

---

## ✅ Firebase Project Setup

1. **Enable Services:**
   - Firebase Auth (Email/Password)
   - Cloud Firestore

2. **iOS Configuration:**
   - Register app in Firebase Console
   - Download `GoogleService-Info.plist` → place in `/ios/Runner/`

3. **Required Packages:**
   ```yaml
   firebase_core: ^2.30.0
   firebase_auth: ^4.17.0
   cloud_firestore: ^5.8.0
   ```

---

## 🔁 Mock vs. Firebase Toggle

**Source:** `lib/env.dart`
```dart
const bool useMockServices = false;
```

**Effect:** All services in `/services/` will switch between:
- `MockXxxService`
- `FirebaseXxxService`
…based on this flag.

---

## 🧱 Firestore Schema (Core Collections)

### `patients/{patientId}`
```json
{
  "name": "John Doe",
  "dob": "1970-01-01",
  "pronouns": "he/him",
  "assignedNurses": ["nurse_001"],
  "riskFlags": ["fall"],
  "createdBy": "nurse_001",
  "createdAt": "2025-06-15T10:00Z"
}
```

### `patients/{id}/shift_notes/{noteId}`
```json
{
  "content": "...",
  "wasAiGenerated": true,
  "createdBy": "nurse_001",
  "createdAt": "2025-06-15T18:30Z"
}
```

### `patients/{id}/vitals/{entryId}`
```json
{
  "temperature": 98.6,
  "pulse": 72,
  "systolic": 120,
  "diastolic": 80,
  "respiratoryRate": 16,
  "oxygenSaturation": 98,
  "recordedBy": "nurse_001",
  "recordedAt": "2025-06-15T18:45Z"
}
```

---

## 🔐 Firestore Security Rules (Planned)

```js
match /patients/{patientId} {
  allow read, write: if request.auth != null
    && request.auth.uid in resource.data.assignedNurses;
}
match /patients/{patientId}/shift_notes/{noteId} {
  allow write: if request.auth != null
    && request.auth.uid == request.resource.data.createdBy;
}
```

---

## 🧪 Testing with Firebase Emulator

1. Install Firebase CLI
2. Run:
   ```sh
   firebase emulators:start
   ```
3. In `.env.dart`, toggle:
   ```dart
   const bool useMockServices = false; // uses Firebase
   ```

---

## 🛠 Strategy for Safe Rollout

- Start each feature in **mock-only mode**
- Validate with real data using `FirebaseXxxService`
- Maintain full swapability via abstract interfaces
- Never allow direct Firestore access in UI or state layers

---

## 🧾 Audit Logging (Planned)

### `audit_log/{logId}`
```json
{
  "event": "gpt_note_generated",
  "patientId": "abc123",
  "noteId": "note456",
  "triggeredBy": "nurse_001",
  "timestamp": "..."
}
```

---

## 🧠 Key Guidelines

| Principle | Rule |
|----------|------|
| Service Isolation | Always use abstract interfaces |
| State Safety | Never call Firestore in widgets |
| Mock Safety | Keep mock logic in `mock_*_service.dart` |
| HIPAA Awareness | No PHI in logs, GPT, or test literals |

---

*Firebase is powerful — but we stay mock-first, audit-safe, and patient-focused.*

<!-- v2.1 update – Jun 22 -->

## 🔄 Updated Mock Enforcement

* The `useMockServices` toggle must affect **all repositories and services**, not just data sources.
* This includes:
  - `AuthService`
  - `GPTService` / note generation
  - XP-related writes
* In production builds, `.env` pre-load is optional — but in testing, always await `.env` before initializing Firebase to prevent init errors.
