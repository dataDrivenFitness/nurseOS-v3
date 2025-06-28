// 📁 lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nurseos_v3/core/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'core/env/env.dart';
import 'features/preferences/data/font_scale_repository.dart';

Future<void> main() async {
  // 🔧 Ensure widget binding is initialized before async tasks
  WidgetsFlutterBinding.ensureInitialized();

  // ──────────────────────────────────────────────────────────────
  // STEP 1: Load .env Configuration
  // Attempts to load .env file. If unavailable, initializes mock env.
  // This is safe for dev/test environments.
  // ──────────────────────────────────────────────────────────────
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ .env not loaded — defaulting to mock mode. Error: $e');
    dotenv.testLoad(fileInput: ''); // Enables `useMockServices` fallback
  }

  logEnv(); // Logs env values (safe subset only)

  // ──────────────────────────────────────────────────────────────
  // STEP 2: Setup Firebase Error Debugging in Dev Mode
  // Captures Firebase usage errors before initialization
  // ──────────────────────────────────────────────────────────────
  if (kDebugMode) {
    FlutterError.onError = (details) {
      if (details.exception is FirebaseException) {
        debugPrint('🔥 EARLY FIREBASE USAGE DETECTED');
        debugPrintStack(stackTrace: details.stack);
      }
      FlutterError.dumpErrorToConsole(details);
    };
  }

  // ──────────────────────────────────────────────────────────────
  // STEP 3: Initialize Firebase with environment-specific options
  // ──────────────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ──────────────────────────────────────────────────────────────
  // STEP 4: Initialize SharedPreferences for dependency injection
  // SharedPrefs are injected using `sharedPreferencesProvider`
  // ──────────────────────────────────────────────────────────────
  final sharedPrefs = await SharedPreferences.getInstance();

  // ──────────────────────────────────────────────────────────────
  // STEP 5: Run the App inside Riverpod ProviderScope
  // Inject SharedPrefs and initialize app shell (`NurseOSApp`)
  // Locale will be controlled reactively inside the app widget
  // ──────────────────────────────────────────────────────────────
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const NurseOSApp(), // now fully reactive to localeController
    ),
  );
}
