// 📁 lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'app.dart'; // ✅ Main app widget
import 'core/env/env.dart'; // useMockServices + logEnv()
import 'features/preferences/data/font_scale_repository.dart'; // ✅ Required for override

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

  // ── 4: SharedPreferences Init (required by FontScaleRepository) ─
  final sharedPrefs = await SharedPreferences.getInstance();

  // ── 5: App Bootstrapping with overrides ────────────────────────
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const NurseOSApp(),
    ),
  );
}
