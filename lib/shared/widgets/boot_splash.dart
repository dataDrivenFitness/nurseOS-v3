// lib/shared/widgets/boot_splash.dart
//
// ─────────────────────────────────────────────────────────────────────────────
//  NurseOS v2 • Boot-time splash wrapper
//  ------------------------------------
//  * Shown **before** the main MaterialApp.router exists.
//  * Hosts both light & dark palettes so the device-level theme is honoured.
//  * Delegates all visuals to the shared SplashScreen (single source of truth).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:nurseos_v3/shared/screens/splash_screen.dart';
import '../../core/theme/app_theme.dart';

class BootSplash extends StatelessWidget {
  const BootSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SplashScreen(), // ← centres AppLoader()
    );
  }
}
