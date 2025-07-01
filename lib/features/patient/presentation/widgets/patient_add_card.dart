import 'package:flutter/material.dart';

import 'package:nurseos_v3/core/theme/animation_tokens.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';

class PatientAddCard extends StatelessWidget {
  const PatientAddCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: InkWell(
        onTap: () => _showAddPatientModal(context),
        borderRadius: BorderRadius.circular(12),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: AnimatedContainer(
          duration: AnimationTokens.medium,
          padding: const EdgeInsets.all(SpacingTokens.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: SpacingTokens.md),
              Text(
                'Add Patient',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPatientModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddPatientModal(),
    );
  }
}

class _AddPatientModal extends StatelessWidget {
  const _AddPatientModal();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan Patient ID'),
              onTap: () {
                // TODO: hook into scanner flow
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Enter Manually'),
              onTap: () {
                // TODO: navigate to manual entry screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
