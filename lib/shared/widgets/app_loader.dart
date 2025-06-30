// lib/shared/widgets/app_loader.dart
//
// ─────────────────────────────────────────────────────────────────────────────
//  NurseOS v2 • Centralised spinner widget
//  ---------------------------------------
//  * Single source of truth for every CircularProgressIndicator in the app.
//  * Automatically adopts the current Theme’s colour palette.
//  * Keeps stroke width consistent with design tokens.
//
//  How to use
//  ──────────
//  • Replace any existing `CircularProgressIndicator()` with
//      `const AppLoader()`
//    in login, profile, prefs, and AsyncValueWidget loaders.
//  • For full-screen blocking UIs, embed this inside the shared
//    SplashScreen (see splash_screen.dart).
//
//  Why centralise?
//  ───────────────
//  1. DRY: change the look once, get it everywhere.
//  2. Dark-mode safety: inherits `Theme.of(context).colorScheme.primary`.
//  3. Token alignment: strokeWidth comes from a design-token constant
//     so it stays in sync with motion/spacing guidelines.
//
//  Next evolutions
//  ───────────────
//  • If design ever wants a branded animation: swap the
//    CircularProgressIndicator for a Lottie/GIF while keeping the API.
//  • If motion tokens change, update `_kLoaderStrokeWidth` and you’re done.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// Design system: keep magic numbers out of widgets.
// In a real build, pull this from `animation_tokens.dart` once stroke widths
// are defined there. For now we hard-code and document it.
const double _kLoaderStrokeWidth = 2.4;

/// A tiny, theme-aware wrapper around [CircularProgressIndicator].
///
/// *Colour* – Inherits `Theme.of(context).colorScheme.primary`, so it
/// automatically swaps hues when the app switches between light and dark.
/// *Size* – Unconstrained; parent widgets decide. Most screens wrap it in
/// `Center` or `SizedBox` as needed.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      strokeWidth: _kLoaderStrokeWidth,
      // No explicit `valueColor`: theme handles it. Keeping the API minimal
      // means fewer call-sites break if we ever migrate away from Material.
    );
  }
}
