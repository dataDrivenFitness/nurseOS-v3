import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/patient_card.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/shared/widgets/cards/ghost_card_action.dart';
import '../../../shared/widgets/error/error_retry_tile.dart';
import '../../../shared/widgets/loading/patient_list_shimmer.dart';
import '../state/patient_providers.dart';

class PatientListScreen extends ConsumerWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(patientProvider);
    final user = ref.watch(authControllerProvider).value;

    final title = (user != null)
        ? 'Nurse ${user.firstName}\'s Patients'
        : 'Assigned Patients';

    return NurseScaffold(
      child: patients.when(
        loading: () => const KeyedSubtree(
          key: Key('patient_list_loading'),
          child: PatientListShimmer(),
        ),
        error: (err, _) => KeyedSubtree(
          key: const Key('patient_list_error'),
          child: ErrorRetryTile(
            message: 'Failed to load patients.',
            onRetry: () => ref.invalidate(patientProvider),
          ),
        ),
        data: (list) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧑‍⚕️ Title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),

              // 📋 Patient List
              Expanded(
                child: ListView.builder(
                  key: const Key('patient_list'),
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length + 1, // extra slot for ghost card
                  itemBuilder: (context, index) {
                    if (index == list.length) {
                      return GhostCardAction(
                        icon: Icons.person_add,
                        label: 'Add Patient',
                        onTap: () => debugPrint('Tapped add patient'),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PatientCard(patient: list[index]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
