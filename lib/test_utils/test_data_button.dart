// lib/test_utils/test_data_button.dart
// Add this button temporarily to any screen to generate test data

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/test_utils/add_test_shifts.dart';
import '../features/agency/state/agency_context_provider.dart';

class TestDataButton extends ConsumerWidget {
  const TestDataButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showTestDataDialog(context, ref),
      icon: const Icon(Icons.science),
      label: const Text('Test Data'),
      backgroundColor: Colors.purple,
    );
  }

  void _showTestDataDialog(BuildContext context, WidgetRef ref) {
    final agencyId = ref.read(currentAgencyIdProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Data Generator'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Generate test available shifts for testing?'),
            const SizedBox(height: 12),
            if (agencyId != null)
              Text(
                'Target Agency: $agencyId',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Text(
                'Warning: No agency selected. Using default_agency.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Adding test shifts...'),
                    ],
                  ),
                ),
              );

              try {
                await TestShiftGenerator.addTestAvailableShifts(agencyId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✅ Test shifts added to ${agencyId ?? 'default_agency'}!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Failed to add test shifts: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add Shifts'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Clearing test shifts...'),
                    ],
                  ),
                ),
              );

              try {
                await TestShiftGenerator.clearTestShifts(agencyId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🧹 Test shifts cleared from ${agencyId ?? 'default_agency'}!',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Failed to clear test shifts: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Clear Shifts'),
          ),
        ],
      ),
    );
  }
}
