import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/patient/state/patient_providers.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/patient_card.dart';
import 'package:nurseos_v3/shared/widgets/loading/patient_list_shimmer.dart';

/// 🧾 Live-updating Patient List using Riverpod + Firestore stream
class PatientListScreen extends ConsumerWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientState = ref.watch(patientProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
      body: patientState.when(
        data: (patients) {
          if (patients.isEmpty) {
            return const Center(child: Text("No patients found"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final patient = patients[index];
              return PatientCard(patient: patient);
            },
          );
        },
        loading: () => const PatientListShimmer(),
        error: (e, _) => Center(
          child: Text(
            '⚠️ Failed to load patients.\n${e.toString()}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
