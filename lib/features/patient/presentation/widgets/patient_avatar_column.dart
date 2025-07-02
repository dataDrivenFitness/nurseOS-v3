import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/patient_extensions.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';

class PatientAvatarColumn extends StatelessWidget {
  final Patient patient;

  const PatientAvatarColumn({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        // 👤 Avatar
        CircleAvatar(
          radius: 36,
          backgroundImage:
              patient.hasProfilePhoto ? NetworkImage(patient.photoUrl!) : null,
          backgroundColor: colors.primary.withAlpha(25),
          child: patient.hasProfilePhoto
              ? null
              : Text(
                  patient.initials,
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                  ),
                ),
        ),

        const SizedBox(height: 6),

        // 🕓 Last Seen
        if (patient.lastSeen != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('M/d/yyyy').format(patient.lastSeen!),
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.subdued,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('h:mm a').format(patient.lastSeen!),
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.subdued,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
