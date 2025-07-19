// 📁 lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ⬅️ Required for orientation control
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nurseos_v3/core/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'core/env/env.dart';

Future<void> main() async {
  // 🔧 Ensure widget binding is initialized before async tasks
  WidgetsFlutterBinding.ensureInitialized();

  // ⬅️ Lock device orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ──────────────────────────────────────────────────────────────
  // STEP 1: Load .env Configuration
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ .env not loaded — defaulting to mock mode. Error: $e');
    dotenv.testLoad(fileInput: '');
  }

  logEnv();

  // ──────────────────────────────────────────────────────────────
  // STEP 2: Setup Firebase Error Debugging in Dev Mode
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ──────────────────────────────────────────────────────────────
  // STEP 4: Initialize SharedPreferences for dependency injection
  final sharedPrefs = await SharedPreferences.getInstance();

  // ──────────────────────────────────────────────────────────────
  // STEP 5: Run the App inside Riverpod ProviderScope
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const NurseOSApp(),
    ),
  );
}
