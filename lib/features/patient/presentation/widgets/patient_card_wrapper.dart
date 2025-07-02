import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/patient_extensions.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'patient_card.dart';

class PatientCardWrapper extends StatelessWidget {
  final Patient patient;

  const PatientCardWrapper({super.key, required this.patient});

  void _logNote(BuildContext context) {
    debugPrint('📝 Log note for ${patient.fullName}');
    // TODO: Implement modal or redirect to note screen
  }

  void _reassignPatient(BuildContext context) {
    debugPrint('🔁 Reassign ${patient.fullName}');
    // TODO: Implement reassign workflow
  }

  void _openPatientDetail(BuildContext context) {
    context.push('/patients/${patient.id}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Slidable(
      key: ValueKey(patient.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.50, // You can fine-tune this
        children: [
          SlidableAction(
            onPressed: (_) => _logNote(context),
            backgroundColor: colors.brandAccent,
            foregroundColor: Colors.white,
            icon: Icons.note_add,
            label: 'Note',
          ),
          SlidableAction(
            onPressed: (_) => _reassignPatient(context),
            backgroundColor: colors.primaryVariant,
            foregroundColor: Colors.white,
            icon: Icons.sync_alt,
            label: 'Reassign',
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openPatientDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: PatientCard(patient: patient),
      ),
    );
  }
}
