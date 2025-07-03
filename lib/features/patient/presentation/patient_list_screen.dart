import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import 'package:nurseos_v3/features/patient/models/patient_extensions.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/patient_card.dart';
import 'package:nurseos_v3/features/profile/state/user_profile_controller.dart';
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
    final userAsync = ref.watch(userProfileStreamProvider);

    final title = userAsync.when(
      data: (user) => "Nurse ${user.firstName}'s Patients",
      loading: () => 'Loading...',
      error: (_, __) => 'Assigned Patients',
    );

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
        data: (list) => Column(
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
                itemCount: list.length + 1,
                itemBuilder: (context, index) {
                  if (index == list.length) {
                    return GhostCardAction(
                      icon: Icons.person_add,
                      label: 'Add Patient',
                      onTap: () => context.push('/patients/add'),
                    );
                  }

                  final patient = list[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Slidable(
                      key: ValueKey(patient.id),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.4,
                        children: [
                          SlidableAction(
                            onPressed: (_) =>
                                debugPrint('Edit ${patient.fullName}'),
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Add Record',
                            borderRadius: BorderRadius.circular(
                                12), // 💅 match card radius
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.push('/patients/${patient.id}'),
                        child: PatientCard(patient: patient),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
