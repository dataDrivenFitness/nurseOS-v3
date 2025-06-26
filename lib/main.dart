import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'core/env/env.dart'; // useMockServices + logEnv()

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1: Load .env ──────────────────────────────────────────────
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ .env not loaded — defaulting to mock mode. Error: $e');
    dotenv.testLoad(fileInput: ''); // allow useMockServices fallback
  }

  logEnv(); // prints USE_MOCK_SERVICES + raw string value

  // ── 2: Dev-only Firebase error trap ───────────────────────────
  if (kDebugMode) {
    FlutterError.onError = (details) {
      if (details.exception is FirebaseException) {
        debugPrint('🔥 EARLY FIREBASE USAGE DETECTED');
        debugPrintStack(stackTrace: details.stack);
      }
      FlutterError.dumpErrorToConsole(details);
    };
  }

  // ── 3: Firebase Initialization (required before GoRouter) ─────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── 4: App Bootstrapping ───────────────────────────────────────
  runApp(
    const ProviderScope(
      child: NurseOSApp(),
    ),
  );
}
