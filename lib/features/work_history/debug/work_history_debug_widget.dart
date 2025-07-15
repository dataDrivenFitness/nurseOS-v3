// lib/features/work_history/debug/work_history_debug_widget.dart
// TEMPORARY DEBUG WIDGET - Add to Records screen to debug

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/work_history/state/work_history_controller.dart';
import 'package:nurseos_v3/shared/models/location_data.dart';

class WorkHistoryDebugWidget extends ConsumerWidget {
  const WorkHistoryDebugWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final workHistoryState = ref.watch(workHistoryControllerProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DEBUG: Work History State',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 16),

            // User info
            Text('User ID: ${user?.uid ?? 'null'}'),
            Text('User Email: ${user?.email ?? 'null'}'),
            Text('Is On Duty: ${user?.isOnDuty ?? 'null'}'),
            Text('Current Session ID: ${user?.currentSessionId ?? 'null'}'),

            const SizedBox(height: 16),

            // Firestore debug
            FutureBuilder<QuerySnapshot>(
              future: user != null
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('workHistory')
                      .limit(5)
                      .get()
                  : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading Firestore data...');
                }

                if (snapshot.hasError) {
                  return Text('Firestore Error: ${snapshot.error}');
                }

                if (user == null) {
                  return const Text('No authenticated user');
                }

                final docs = snapshot.data?.docs ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Firestore work sessions: ${docs.length}'),
                    ...docs.map((doc) => Text('  - ${doc.id}: ${doc.data()}')),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Test shift creation
            Row(
              children: [
                ElevatedButton(
                  onPressed: workHistoryState.isLoading
                      ? null
                      : () => _createTestShift(ref, user),
                  child: const Text('Create Test Shift'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _debugCurrentState(ref),
                  child: const Text('Debug State'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTestShift(WidgetRef ref, user) async {
    if (user == null) return;

    try {
      final controller = ref.read(workHistoryControllerProvider.notifier);

      // Create mock location data
      final location = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        accuracy: 5.0,
        address: 'Test Hospital, 123 Test St, San Francisco, CA',
        facility: 'Test Hospital',
        timestamp: DateTime.now(),
      );

      print('🧪 Creating test shift...');

      // Start a test shift
      final sessionId = await controller.startDutySession(
        location: location,
        notes: 'Test shift created for debugging',
      );

      print('✅ Test shift created: $sessionId');

      // Wait a moment, then end it
      await Future.delayed(const Duration(seconds: 2));

      await controller.endDutySession(
        location: location,
        notes: 'Test shift completed',
      );

      print('✅ Test shift completed');
    } catch (e) {
      print('❌ Error creating test shift: $e');
    }
  }

  void _debugCurrentState(WidgetRef ref) {
    final controller = ref.read(workHistoryControllerProvider.notifier);
    // This will call the debug method if it exists
    print('🔍 Debugging current state...');
    // You can add more debug calls here
  }
}
