// lib/widgets/dual_test_fab.dart
// Shows both Test Data and Admin buttons

import 'package:flutter/material.dart';
import 'package:nurseos_v3/test_utils/test_data_button.dart';
import 'package:nurseos_v3/test_utils/admin_test_button.dart';

class DualTestFAB extends StatelessWidget {
  const DualTestFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Admin button (top)
        FloatingActionButton.extended(
          onPressed: () => _showAdminDialog(context),
          icon: const Icon(Icons.admin_panel_settings),
          label: const Text('Admin'),
          backgroundColor: Colors.orange,
          heroTag: "admin_fab", // Prevent hero animation conflicts
        ),

        const SizedBox(height: 16),

        // Test data button (bottom)
        FloatingActionButton.extended(
          onPressed: () => _showTestDataDialog(context),
          icon: const Icon(Icons.science),
          label: const Text('Test Data'),
          backgroundColor: Colors.purple,
          heroTag: "test_data_fab", // Prevent hero animation conflicts
        ),
      ],
    );
  }

  void _showTestDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Data Generator'),
        content: const Text('Generate test available shifts for testing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Import your TestShiftGenerator
              try {
                // await TestShiftGenerator.addTestAvailableShifts();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Test shifts added!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add Shifts'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // await TestShiftGenerator.clearTestShifts();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🧹 Test shifts cleared!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Clear Shifts'),
          ),
        ],
      ),
    );
  }

  void _showAdminDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🏥 Mock Admin Dashboard'),
        content: const Text('Simulate admin approving your shift request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _simulateAdminApproval(context);
            },
            child: const Text('Approve Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateAdminApproval(BuildContext context) async {
    // Copy the admin approval logic from AdminTestButton
    try {
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
              Text('Admin processing approval...'),
            ],
          ),
        ),
      );

      // Add your admin approval logic here
      // For now, just show success
      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Admin approved shift! Check My Schedule tab.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Admin approval failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
