import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/preferences/domain/patient_display_option.dart';
import '../../auth/state/auth_controller.dart';
import '../domain/display_preferences.dart';
import '../data/display_preferences_repository.dart';

class DisplayPreferencesController extends AsyncNotifier<DisplayPreferences> {
  @override
  Future<DisplayPreferences> build() async {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return DisplayPreferences.defaults();
    return ref.read(displayPreferencesRepositoryProvider).fetch(user.uid);
  }

  Future<void> toggle(PatientDisplayOption option) async {
    final current = state.value ?? DisplayPreferences.defaults();
    final updated = current.toggle(option);
    state = AsyncValue.data(updated);

    final user = ref.read(authControllerProvider).value;
    if (user != null) {
      await ref
          .read(displayPreferencesRepositoryProvider)
          .save(user.uid, updated);
    }
  }
}

final displayPreferencesControllerProvider =
    AsyncNotifierProvider<DisplayPreferencesController, DisplayPreferences>(
        DisplayPreferencesController.new);
