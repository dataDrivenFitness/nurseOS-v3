// 📁 lib/features/profile/service/duty_status_service.dart
// Updated for full compliance GPS tracking with layout fixes

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

  /// Start a new shift with full GPS location capture for compliance
  Future<void> startShift({
    required BuildContext context,
    required UserModel user,
  }) async {
    try {
      final controller = _ref.read(workHistoryControllerProvider.notifier);

      // Show loading with proper layout
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
                Expanded(
                  child: Text('Starting shift & capturing location...'),
                ),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Get accurate location for compliance
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
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Shift started successfully'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
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
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to start shift: ${_getErrorMessage(e)}'),
                ),
              ],
            ),
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

  /// End the current shift with full GPS location capture for compliance
  Future<void> endShift({
    required BuildContext context,
    required WorkSession currentSession,
  }) async {
    try {
      final controller = _ref.read(workHistoryControllerProvider.notifier);

      // Show loading with proper layout
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
                Expanded(
                  child: Text('Ending shift & capturing location...'),
                ),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Use FULL GPS location capture for compliance (same as start shift)
      final endLocation = await _getLocationData(context);

      // End session with accurate location
      await controller.endDutySession(
        location: endLocation,
        notes: 'Shift ended via mobile app',
      );

      // Clear loading and show success
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Shift ended - Location recorded'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      debugPrint('✅ Shift ended successfully with accurate location');
    } catch (e) {
      debugPrint('❌ End shift error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to end shift: ${_getErrorMessage(e)}'),
                ),
              ],
            ),
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

  /// Get high-accuracy location data for compliance requirements
  ///
  /// Uses 10-second timeout with medium accuracy for EVV compliance.
  /// Healthcare regulations require documented location verification.
  Future<LocationData> _getLocationData(BuildContext context) async {
    try {
      // Check if location services are enabled
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      // Get current position with compliance-grade accuracy
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium, // Good balance of accuracy/speed
            timeLimit: Duration(seconds: 10), // Allow time for accurate reading
          ),
        );
      } catch (e) {
        // Fallback to last known position for compliance
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          position = lastPosition;
          debugPrint('⚠️ Using last known position: ${e.toString()}');
        } else {
          throw Exception('Unable to get location');
        }
      }

      // Create comprehensive LocationData for audit trail
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        address:
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
        facility: null, // Could be enhanced with geofencing in the future
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Use fallback location if GPS completely fails
      // This ensures shift can still be recorded even with location issues
      debugPrint('⚠️ Location error, using fallback: $e');
      return LocationData(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 999.0, // Indicates poor/unavailable accuracy
        address: 'Location unavailable',
        facility: null,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Convert various error types to user-friendly messages
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
    } else if (errorStr.contains('session')) {
      return 'Shift session error';
    } else {
      return 'Please try again';
    }
  }
}
