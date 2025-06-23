import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_theme.dart';
import 'core/bootstrap.dart';

/// NurseOSApp is the root of the widget tree. It sets up routing, theming, and platform configuration.
class NurseOSApp extends StatelessWidget {
  const NurseOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NurseOS v3',

      // ✅ Apply custom light and dark themes from AppTheme
      theme: AppTheme.light(), // returns ThemeData
      darkTheme: AppTheme.dark(), // returns ThemeData
      themeMode: ThemeMode.system, // system theme toggle support

      // 🔁 Routing configuration is defined in core/bootstrap.dart
      routerConfig: createRouter(),
    );
  }
}
