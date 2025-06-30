// lib/shared/widgets/splash_screen.dart
//
// ─────────────────────────────────────────────────────────────────────────────
//  NurseOS v2 • Shared “waiting” screen
//  -------------------------------------
//  • Used by both the pre-bootstrap BootSplash (first app launch) and the
//    GoRouter ‘/splash’ fallback while auth/state providers resolve.
//  • The actual spinner visuals are delegated to AppLoader so we have a
//    single place to change strokeWidth or colours in future.
//
//  Architectural notes
//  ───────────────────
//  • Presentation-only, no business logic → belongs in shared/widgets.
//  • Keep this widget tiny; complex logic belongs in AsyncValueWidget or
//    feature-level UIs.
//  • Never hard-code colours inside; `AppLoader` takes care of theme
//    adaptation via Theme.of(context).colorScheme.primary.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:nurseos_v3/shared/widgets/app_loader.dart';

/// A minimal, theme-aware splash screen that simply centers an [AppLoader].
///
/// Shown in three scenarios:
/// * **Boot-time** – wrapped by `BootSplash` while core providers load.
/// * **Auth redirect** – GoRouter pushes `/splash` when Firebase auth
///   state is still resolving.
/// * **Manual routes** – any feature may `context.go('/splash')` if it
///   needs a full-screen blocking loader.
///
/// Do **not** add timers, navigation, or side-effects here; that belongs
/// in the caller or in an `AsyncNotifier`.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the correct surface colour (light or dark) from
    // the nearest MaterialApp. Center keeps the loader in the middle of
    // the viewport regardless of device size or rotation.
    return const Scaffold(
      body: Center(
        child: AppLoader(), // one-liner = single source of truth
      ),
    );
  }
}
