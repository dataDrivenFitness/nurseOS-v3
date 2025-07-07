// 📁 lib/features/profile/service/duty_status_service.dart
// Updated to use your existing LocationData model with extensions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nurseos_v3/shared/models/location_data.dart';

import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/features/work_history/models/work_session.dart';
import 'package:nurseos_v3/features/work_history/state/work_history_controller.dart';

final dutyStatusServiceProvider = Provider<DutyStatusService>((ref) {
  return DutyStatusService(ref);
});

class DutyStatusService {
  final Ref _ref;

  DutyStatusService(this._ref);

  /// Start a new shift with location capture
  Future<void> startShift({
    required BuildContext context,
    required UserModel user,
  }) async {
    try {
      final controller = _ref.read(workHistoryControllerProvider.notifier);

      // Show loading
      if (context.mounted) {
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
                Text('Starting shift...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Get location using your existing model
      final locationData = await _getLocationData(context);

      // Start session
      final sessionId = await controller.startDutySession(
        location: locationData,
        notes: 'Shift started via mobile app',
      );

      // Clear loading and show success
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shift started successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      debugPrint('✅ Shift started: $sessionId');
    } catch (e) {
      debugPrint('❌ Start shift error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start shift: ${_getErrorMessage(e)}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => startShift(context: context, user: user),
            ),
          ),
        );
      }
    }
  }

  /// End the current shift
  Future<void> endShift({
    required BuildContext context,
    required WorkSession currentSession,
  }) async {
    try {
      final controller = _ref.read(workHistoryControllerProvider.notifier);

      // Show loading
      if (context.mounted) {
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
                Text('Ending shift...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Use simple location for end (leveraging your existing model)
      final endLocation = LocationData(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 999.0,
        address: 'Location not captured',
        facility: null,
        timestamp: DateTime.now(),
      );

      // End session
      await controller.endDutySession(
        location: endLocation,
        notes: 'Shift ended via mobile app',
      );

      // Clear loading and show success
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shift ended successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      debugPrint('✅ Shift ended successfully');
    } catch (e) {
      debugPrint('❌ End shift error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to end shift: ${_getErrorMessage(e)}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () =>
                  endShift(context: context, currentSession: currentSession),
            ),
          ),
        );
      }
    }
  }

  /// Get location data using your existing comprehensive model
  Future<LocationData> _getLocationData(BuildContext context) async {
    try {
      // Check if location services are enabled
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      // Try to get current position with timeout
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (e) {
        // Fallback to last known position
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          position = lastPosition;
        } else {
          throw Exception('Unable to get location');
        }
      }

      // Use your comprehensive LocationData model
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        address:
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
        facility: null, // Could be set based on geofencing in the future
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Use fallback location if GPS fails
      debugPrint('⚠️ Location error, using fallback: $e');
      return LocationData(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 999.0,
        address: 'Location unavailable',
        facility: null,
        timestamp: DateTime.now(),
      );
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('permission')) {
      return 'Location permission required';
    } else if (errorStr.contains('location')) {
      return 'Location services needed';
    } else if (errorStr.contains('network') || errorStr.contains('internet')) {
      return 'Check internet connection';
    } else if (errorStr.contains('timeout')) {
      return 'Request timed out';
    } else {
      return 'Please try again';
    }
  }
}
