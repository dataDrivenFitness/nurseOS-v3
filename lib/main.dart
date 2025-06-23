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

  /// ── 1: Load .env ──────────────────────────────────────────────
  final envFile = File('.env');
  final exists = await envFile.exists();
  debugPrint('[bootstrap] .env exists: $exists');

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ .env not loaded — defaulting to mock mode. Error: $e');
    dotenv.testLoad(fileInput: ''); // init empty fallback
  }

  logEnv(); // log current USE_MOCK_SERVICES mode

  /// ── 2: Dev-only early Firestore guard ─────────────────────────
  if (kDebugMode) {
    FlutterError.onError = (details) {
      if (details.exception is FirebaseException) {
        debugPrint('🔥 EARLY FIREBASE USAGE');
        debugPrintStack(stackTrace: details.stack);
      }
      FlutterError.dumpErrorToConsole(details);
    };
  }

  /// ── 3: Firebase Init ──────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// ── 4: App Entry ──────────────────────────────────────────────
  runApp(const ProviderScope(child: NurseOSApp()));
}
