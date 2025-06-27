import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/preferences/data/font_scale_repository.dart';

/// Controls app-wide text scaling across NurseOS.
///
/// Uses SharedPreferences for fast boot and Firestore for cloud sync.
class FontScaleController extends AsyncNotifier<double> {
  AbstractFontScaleRepository? _repository;
  String? _uid;

  @override
  Future<double> build() async {
    final auth = ref.watch(authControllerProvider).valueOrNull;

    // Anonymous fallback
    if (auth == null || auth.uid.isEmpty) {
      debugPrint('⚠️ Skipping font scale load — auth unavailable or uid empty');
      return 1.0;
    }

    _uid ??= auth.uid;
    _repository ??= ref.read(fontScaleRepositoryProvider);

    try {
      final saved = await _repository!.getFontScale(_uid!);
      return saved ?? 1.0;
    } catch (e, st) {
      debugPrint('❌ Font scale load failed: $e');
      debugPrintStack(stackTrace: st);
      return 1.0;
    }
  }

  /// Sets new scale and persists it locally and in Firestore.
  Future<void> updateScale(double newScale) async {
    final repo = _repository;
    final uid = _uid;

    if (repo == null || uid == null || uid.isEmpty) {
      debugPrint('⚠️ Cannot update font scale — repo or uid is null');
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.setFontScale(uid, newScale);
      return newScale;
    });
  }
}

/// Async Riverpod provider for font scale.
final fontScaleControllerProvider =
    AsyncNotifierProvider<FontScaleController, double>(FontScaleController.new);
