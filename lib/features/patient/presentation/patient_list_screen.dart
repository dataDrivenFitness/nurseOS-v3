import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/patient_card.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/patient_add_card.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
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
        loading: () {
          debugPrint('[UI] State: Loading');
          return const KeyedSubtree(
            key: Key('patient_list_loading'),
            child: PatientListShimmer(),
          );
        },
        error: (err, _) {
          debugPrint('[UI] State: Error → $err');
          return KeyedSubtree(
            key: const Key('patient_list_error'),
            child: ErrorRetryTile(
              message: 'Failed to load patients.',
              onRetry: () => ref.invalidate(patientProvider),
            ),
          );
        },
        data: (list) {
          debugPrint(
              '[UI] State: ${list.isEmpty ? "Empty" : "Loaded with ${list.length} patients"}');

          return ListView.builder(
            key: const Key('patient_list'),
            padding: const EdgeInsets.all(16),
            itemCount: list.isEmpty ? 2 : list.length + 1,
            itemBuilder: (context, index) {
              if (list.isEmpty) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Text(
                        'No patients assigned.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  );
                } else {
                  return const PatientAddCard();
                }
              }

              if (index < list.length) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PatientCard(patient: list[index]),
                );
              }

              return const PatientAddCard();
            },
          );
        },
      ),
    );
  }
}
