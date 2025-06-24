import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/patient_card.dart';
import '../../../shared/widgets/error/error_retry_tile.dart';
import '../../../shared/widgets/loading/patient_list_shimmer.dart';
import '../state/patient_providers.dart';

class PatientListScreen extends ConsumerWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(patientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assigned Patients',
          key: Key('assignedPatientsTitle'), // 🧪 test identifier
        ),
      ),
      body: patients.when(
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
          if (list.isEmpty) {
            debugPrint('[UI] State: Empty');
            return const Center(
              key: Key('patient_list_empty'),
              child: Text('No patients assigned.'),
            );
          }

          debugPrint('[UI] State: Loaded with ${list.length} patients');
          return ListView.builder(
            key: const Key('patient_list'),
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PatientCard(patient: list[index]),
            ),
          );
        },
      ),
    );
  }
}
