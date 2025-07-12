import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import '../state/shift_pool_provider.dart';
import '../state/shift_request_controller.dart';

class ShiftPoolScreen extends ConsumerWidget {
  const ShiftPoolScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shifts = ref.watch(shiftPoolProvider);
    final controller = ref.read(shiftRequestControllerProvider);
    final user = ref.watch(authControllerProvider).value;

    // Show loading if user not authenticated
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Available Shifts')),
      body: shifts.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('No shifts available.'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final shift = data[index];
              return ListTile(
                title: Text(shift.location),
                subtitle: Text(
                    '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await controller.requestShift(
                        shift.id, user.uid); // ✅ Fixed: Use real user ID
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Shift requested')),
                      );
                    }
                  },
                  child: const Text('Request'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
