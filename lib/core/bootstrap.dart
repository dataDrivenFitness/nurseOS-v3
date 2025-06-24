import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'router/app_router.dart';
import 'package:nurseos_v3/firebase_options.dart';

Future<void> bootstrap(FutureOr<Widget> Function(GoRouter) builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 Load environment config (.env)
  await dotenv.load(fileName: '.env');

  // 🔥 Initialize Firebase (conditionally)
  const useFirebase = bool.fromEnvironment('USE_FIREBASE', defaultValue: true);
  if (useFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // 🧪 Setup Provider container for DI
  final container = ProviderContainer();

  // 🧭 Get the router from our provider
  final router = container.read(appRouterProvider);

  // 🏗 Build the app widget (await in case it's async)
  final app = await builder(router);

  // 🚨 Wrap in error boundary for global uncaught errors
  runZonedGuarded(
    () => runApp(
      UncontrolledProviderScope(
        container: container,
        child: app,
      ),
    ),
    (error, stack) {
      debugPrint('🧨 Uncaught bootstrap error: $error\n$stack');
      // TODO: Hook into Sentry/Crashlytics
    },
  );
}
