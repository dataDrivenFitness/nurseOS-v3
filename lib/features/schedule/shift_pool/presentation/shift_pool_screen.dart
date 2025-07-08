// lib/features/schedule/shift_pool/presentation/shift_pool_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurseos_v3/test_utils/test_data_button.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../test_utils/add_test_shifts.dart';
import '../../../auth/state/auth_controller.dart';
import '../state/shift_pool_provider.dart';
import '../state/shift_request_controller.dart';

class ShiftPoolScreen extends ConsumerWidget {
  const ShiftPoolScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shifts = ref.watch(shiftPoolProvider);
    final controller = ref.read(shiftRequestControllerProvider);
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      body: shifts.when(
        data: (data) {
          // 🔍 DEBUG: Let's see what we're getting
          debugPrint('🔍 ShiftPoolScreen received ${data.length} shifts');
          for (final shift in data) {
            debugPrint('  - ${shift.id}: ${shift.location} (${shift.status})');
          }

          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  const Text(
                    'No shifts available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  const Text(
                    'Available shifts will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  // 🔍 DEBUG: Add manual refresh button
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('🔄 Manual refresh triggered');
                      ref.refresh(shiftPoolProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(SpacingTokens.md),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final shift = data[index];
              final hasRequested =
                  shift.requestedBy.contains(user?.uid) ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: SpacingTokens.md),
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location header
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          Expanded(
                            child: Text(
                              shift.location,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: SpacingTokens.md),

                      // Time and duration
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          Text(
                            '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDuration(shift.startTime, shift.endTime),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                          ),
                        ],
                      ),

                      // Request status and button
                      const SizedBox(height: SpacingTokens.md),
                      Row(
                        children: [
                          if (shift.requestedBy.isNotEmpty) ...[
                            Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: SpacingTokens.sm),
                            Text(
                              '${shift.requestedBy.length} request${shift.requestedBy.length != 1 ? 's' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                            const Spacer(),
                          ] else
                            const Spacer(),

                          // Request button
                          ElevatedButton.icon(
                            onPressed: hasRequested || user == null
                                ? null
                                : () => _requestShift(
                                    context, ref, shift.id, user!.uid),
                            icon: Icon(
                              hasRequested ? Icons.check : Icons.add,
                              size: 16,
                            ),
                            label: Text(
                              hasRequested ? 'Requested' : 'Request',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasRequested
                                  ? Colors.green
                                  : Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () {
          debugPrint('🔄 ShiftPoolScreen: Loading shifts...');
          return const Center(child: CircularProgressIndicator());
        },
        error: (e, st) {
          debugPrint('❌ ShiftPoolScreen error: $e');
          debugPrint('Stack trace: $st');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  'Error loading shifts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  e.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpacingTokens.lg),
                ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('🔄 Error refresh triggered');
                    ref.refresh(shiftPoolProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      // Add both test buttons - stacked vertically
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Admin test button (orange)
          FloatingActionButton.extended(
            onPressed: () => _showAdminDialog(context),
            icon: const Icon(Icons.admin_panel_settings),
            label: const Text('Admin'),
            backgroundColor: Colors.orange,
            heroTag: "admin_fab",
          ),

          const SizedBox(height: 16),

          // Test data button (purple)
          const TestDataButton(),
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
    try {
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
              Text('Admin processing approval...'),
            ],
          ),
        ),
      );

      // Find a shift with requests and approve it
      final firestore = FirebaseFirestore.instance;

      // Get the current user from Riverpod
      final container = ProviderScope.containerOf(context);
      final userAsync = container.read(authControllerProvider);
      final user = userAsync.value;

      if (user == null) {
        throw Exception('No authenticated user');
      }

      final query = await firestore
          .collection('shifts')
          .where('status', isEqualTo: 'available')
          .limit(10)
          .get();

      String? shiftToApprove;

      for (final doc in query.docs) {
        final data = doc.data();
        final requestedBy = List<String>.from(data['requestedBy'] ?? []);

        if (requestedBy.contains(user.uid)) {
          shiftToApprove = doc.id;
          break;
        }
      }

      if (shiftToApprove == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No pending requests found for you'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Approve the shift
      final shiftRef = firestore.collection('shifts').doc(shiftToApprove);
      await firestore.runTransaction((tx) async {
        tx.update(shiftRef, {
          'assignedTo': user.uid,
          'status': 'accepted',
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': 'mock_admin_uid',
        });
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('✅ Admin approved your shift! Check My Schedule tab.'),
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

  String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Future<void> _requestShift(
    BuildContext context,
    WidgetRef ref,
    String shiftId,
    String userUid,
  ) async {
    final controller = ref.read(shiftRequestControllerProvider);

    try {
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
              Text('Requesting shift...'),
            ],
          ),
        ),
      );

      await controller.requestShift(shiftId, userUid);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Shift requested successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to request shift: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
