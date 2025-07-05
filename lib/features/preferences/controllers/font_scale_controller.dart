import 'package:flutter/foundation.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/preferences/data/font_scale_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'font_scale_controller.g.dart';

/// Controls app-wide text scaling (read-once + writes).
class FontScaleController extends AsyncNotifier<double> {
  AbstractFontScaleRepository? _repo;
  String? _uid;

  @override
  Future<double> build() async {
    final auth = ref.watch(authControllerProvider).valueOrNull;
    if (auth == null || auth.uid.isEmpty) {
      debugPrint('⚠️  Skipping font scale load — no user');
      return 1.0;
    }

    _uid ??= auth.uid;
    _repo ??= ref.read(fontScaleRepositoryProvider);

    try {
      return (await _repo!.getFontScale(_uid!)) ?? 1.0;
    } catch (e, st) {
      debugPrint('❌ Font scale load failed: $e');
      debugPrintStack(stackTrace: st);
      return 1.0;
    }
  }

  /*───────────────────────────────
            Public updater
  ───────────────────────────────*/
  Future<void> updateScale(double newScale) async {
    final repo = _repo;
    final uid = _uid;
    if (repo == null || uid == null || uid.isEmpty) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.setFontScale(uid, newScale);
      return newScale;
    });
  }
}

/// Allows widgets to *write*.
final fontScaleControllerProvider =
    AsyncNotifierProvider<FontScaleController, double>(FontScaleController.new);

/// 🆕 Live Firestore stream → UI reacts instantly.
@Riverpod(keepAlive: true)
Stream<double> fontScaleStream(FontScaleStreamRef ref) async* {
  final auth = await ref.watch(authControllerProvider.future);
  final uid = auth?.uid ?? '';

  if (uid.isEmpty) {
    yield 1.0; // guest fallback
    return;
  }

  final repo = ref.watch(fontScaleRepositoryProvider);

  // Emit cached value first for fast paint
  final cached = await repo.getFontScale(uid);
  yield cached ?? 1.0;

  // Then forward real-time Firestore updates
  await for (final scale in repo.watchFontScale(uid)) {
    yield scale;
  }
}
