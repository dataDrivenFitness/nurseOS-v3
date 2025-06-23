import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app.dart';
import '/core/env/env.dart'; // useMockServices + logEnv()

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final envFile = File('.env');
  print('[bootstrap] .env exists: ${await envFile.exists()}');

  /* 1 ─ Load .env (safe fallback if file absent) */
  try {
    await dotenv.load(); // looks for .env asset
  } catch (e) {
    debugPrint('⚠️  .env not found – defaulting to mock mode ($e)');
    // Mark dotenv as "initialised" with an empty map (requires ≥5.0)
    dotenv.testLoad(fileInput: '');
  }
  logEnv(); // prints USE_MOCK_SERVICES

  /* 2 ─ Dev-only early-Firestore detector */
  if (kDebugMode) {
    FlutterError.onError = (details) {
      if (details.exception is FirebaseException) {
        debugPrint('🔥 EARLY FIREBASE USAGE');
        debugPrintStack(stackTrace: details.stack);
      }
      FlutterError.dumpErrorToConsole(details);
    };
  }

  /* 3 ─ Initialise Firebase once */
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /* 4 ─ Run the app */
  runApp(const ProviderScope(child: NurseOSApp()));
}
