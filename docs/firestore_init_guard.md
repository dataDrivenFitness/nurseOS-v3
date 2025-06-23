## ⚠️ Firestore Initialization Guard (Runtime)

> Preventing `NotInitializedError` in Flutter + Firebase apps  
> _(Added 2025-06-22 after patient-list crash)_

### 1 Block until Firebase is ready

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: NurseOSApp()));
}
```

*Nothing in the widget tree runs before `initializeApp` finishes.*

---

### 2 Never touch `FirebaseFirestore.instance` in a top-level variable

| ❌ Anti-pattern (crashes) | ✅ Safe pattern |
|--------------------------|----------------|
| `final patientsRef = FirebaseFirestore.instance.collection('patients');` | `CollectionReference patientsRef() => FirebaseFirestore.instance.collection('patients');` |
| `static final coll = …` inside a model | `CollectionReference coll(FirebaseFirestore db) => db.collection('…');` |
| Singleton grabs the instance in its constructor | Pass `FirebaseFirestore db` into the constructor |

**Rule of thumb:**  
> *If code runs at **import-time**, it must **not** hit Firestore.*

---

### 3 Repository template

```dart
class FirebasePatientRepository {
  CollectionReference<Patient> get _patients => typedPatientsCollection();

  Future<List<Patient>> getAllPatients() async {
    final snap = await _patients.get();
    return snap.docs.map((d) => d.data()).toList();
  }
}
```

*Getter defers Firestore access until after init.*

---

### 4 Test checklist before every commit

- [ ] **Grep** for `FirebaseFirestore.instance` outside functions/methods.
- [ ] **Cold-start** the app; verify no `NotInitializedError` in console.
- [ ] **Unit test**: repository methods succeed with emulator running.

---

_Keep this guard in mind whenever adding a new model, helper, or service._


<!-- v2.1 update – Jun 22 -->

## 🔒 CI Safety Enhancement (Suggested)

* Add a pre-commit grep rule to detect bad Firestore access:

```sh
grep -r 'FirebaseFirestore.instance' lib/ | grep -v '() =>'
```

* Block commits if instance access appears outside of a method or function.

_This rule protects against `NotInitializedError` caused by import-time Firebase access._
