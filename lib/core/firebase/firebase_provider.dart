import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/firebase_options.dart';

/// Completes when Firebase is ready.
final firebaseAppProvider = FutureProvider<FirebaseApp>((ref) async {
  WidgetsFlutterBinding.ensureInitialized();
  return Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
});

/// Synchronous provider that **throws** while Firebase is still loading.
/// Replaces the old `.requireData`.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  final asyncApp = ref.watch(firebaseAppProvider);
  final app = asyncApp.asData?.value; // ← riverpod 2.x pattern
  if (app == null) {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'Firebase not initialised yet',
    );
  }
  return FirebaseFirestore.instanceFor(app: app);
});
