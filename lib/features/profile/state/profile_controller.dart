import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/gamification/state/xp_repository.dart';

/// Holds profile data (user info + XP)
final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileViewModel>(
  ProfileController.new,
);

class ProfileController extends AsyncNotifier<ProfileViewModel> {
  @override
  Future<ProfileViewModel> build() async {
    final user = await ref.watch(authControllerProvider.future);
    final xpRepo = ref.watch(xpRepositoryProvider);

    final xp = await xpRepo.getXp(user!.uid);
    return ProfileViewModel(user: user, xp: xp);
  }
}

class ProfileViewModel {
  final UserModel user;
  final int xp;
  const ProfileViewModel({required this.user, required this.xp});
}
