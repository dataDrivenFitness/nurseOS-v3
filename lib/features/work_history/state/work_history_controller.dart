// 📁 lib/features/work_history/state/work_history_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/work_history/models/work_session.dart';
import 'package:nurseos_v3/shared/models/location_data.dart';

// ═══════════════════════════════════════════════════════════════════
// 🔥 MAIN CURRENT SESSION PROVIDER - This drives the shift button state
// ═══════════════════════════════════════════════════════════════════

final currentWorkSessionStreamProvider = StreamProvider<WorkSession?>((ref) {
  final authState = ref.watch(authControllerProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);

      // Real-time stream of user document to watch currentSessionId changes
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .asyncMap((userSnapshot) async {
        try {
          if (!userSnapshot.exists) return null;

          final userData = userSnapshot.data()!;
          final isOnDuty = userData['isOnDuty'] as bool? ?? false;
          final currentSessionId = userData['currentSessionId'] as String?;

          // If not on duty or no session ID, return null
          if (!isOnDuty || currentSessionId == null) return null;

          // Fetch the actual session document
          final sessionSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('workHistory')
              .doc(currentSessionId)
              .get();

          if (!sessionSnapshot.exists) {
            debugPrint('⚠️ Session document not found: $currentSessionId');
            return null;
          }

          final sessionData = sessionSnapshot.data()!;
          return WorkSession.fromJson({
            ...sessionData,
            'sessionId': sessionSnapshot.id,
          });
        } catch (e) {
          if (e is FirebaseException && e.code == 'permission-denied') {
            return null; // Handle logout gracefully
          }
          debugPrint('❌ Error in currentWorkSessionStreamProvider: $e');
          return null;
        }
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ═══════════════════════════════════════════════════════════════════
// 📊 WORK HISTORY QUERY PROVIDERS
// ═══════════════════════════════════════════════════════════════════

class WorkHistoryParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;

  const WorkHistoryParams({
    this.startDate,
    this.endDate,
    this.limit = 50,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkHistoryParams &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(startDate, endDate, limit);
}

final workHistoryStreamProvider =
    StreamProvider.family<List<WorkSession>, WorkHistoryParams>((ref, params) {
  final authState = ref.watch(authControllerProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);

      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workHistory')
          .orderBy('startTime', descending: true);

      // Apply date filters
      if (params.startDate != null) {
        query = query.where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(params.startDate!));
      }

      if (params.endDate != null) {
        query = query.where('startTime',
            isLessThan: Timestamp.fromDate(params.endDate!));
      }

      query = query.limit(params.limit);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                return WorkSession.fromJson({
                  ...doc.data(),
                  'sessionId': doc.id,
                });
              } catch (e) {
                debugPrint('❌ Error parsing session ${doc.id}: $e');
                return null;
              }
            })
            .whereType<WorkSession>()
            .toList();
      });
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// ═══════════════════════════════════════════════════════════════════
// 🎯 MAIN WORK HISTORY CONTROLLER
// ═══════════════════════════════════════════════════════════════════

final workHistoryControllerProvider =
    AsyncNotifierProvider<WorkHistoryController, void>(
  WorkHistoryController.new,
);

class WorkHistoryController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Nothing to initialize
  }

  /// Start a new duty session
  Future<String> startDutySession({
    required LocationData location,
    String? notes,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Generate session ID
      final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';

      // ✅ FIX: Use explicit Timestamp instead of FieldValue.serverTimestamp()
      final now = Timestamp.fromDate(DateTime.now());

      debugPrint('🚀 Starting shift: $sessionId for user ${user.uid}');

      // Use batch for atomic operation
      final batch = FirebaseFirestore.instance.batch();

      // 1. Create work session document using correct field mapping
      final sessionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workHistory')
          .doc(sessionId);

      // Map LocationData to Firestore fields correctly
      batch.set(sessionRef, {
        'sessionId': sessionId,
        'userId': user.uid,
        'startTime': now, // ✅ Use explicit timestamp
        'startLatitude': location.latitude,
        'startLongitude': location.longitude,
        'startAccuracy': location.accuracy,
        'startAddress':
            location.address ?? '${location.latitude}, ${location.longitude}',
        'startLocationTimestamp': Timestamp.fromDate(location.timestamp),
        'createdAt': now, // ✅ Use explicit timestamp
        'updatedAt': now, // ✅ Use explicit timestamp
        'notes': notes ?? 'Shift started via mobile app',
        // Map facility to the correct field name if WorkSession expects it
        'facility': location.facility,
        // Initialize end fields
        'endTime': null,
        'endLatitude': null,
        'endLongitude': null,
        'endAccuracy': null,
        'endAddress': null,
        'endLocationTimestamp': null,
        'duration': null,
      });

      // 2. Update user duty status - can still use FieldValue.serverTimestamp() here
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      batch.update(userRef, {
        'isOnDuty': true,
        'currentSessionId': sessionId,
        'lastStatusChange':
            FieldValue.serverTimestamp(), // This is fine for user doc
      });

      // Execute batch
      await batch.commit();

      debugPrint('✅ Shift started successfully: $sessionId');
      state = const AsyncValue.data(null);

      return sessionId;
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to start shift: $e');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// End the current duty session
  Future<void> endDutySession({
    required LocationData location,
    String? notes,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user');

      debugPrint('🛑 Ending shift for user ${user.uid}');

      // Get current session info
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) throw Exception('User document not found');

      final userData = userDoc.data()!;
      final currentSessionId = userData['currentSessionId'] as String?;
      final isOnDuty = userData['isOnDuty'] as bool? ?? false;

      if (!isOnDuty || currentSessionId == null) {
        throw Exception('No active session to end');
      }

      // Get session document
      final sessionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workHistory')
          .doc(currentSessionId);

      final sessionDoc = await sessionRef.get();
      if (!sessionDoc.exists) {
        throw Exception('Session document not found: $currentSessionId');
      }

      final sessionData = sessionDoc.data()!;

      // Parse start time (handle both string and timestamp)
      DateTime startTime;
      final startTimeRaw = sessionData['startTime'];

      if (startTimeRaw is Timestamp) {
        startTime = startTimeRaw.toDate();
      } else if (startTimeRaw is String) {
        startTime = DateTime.parse(startTimeRaw);
      } else {
        throw Exception(
            'Invalid startTime format: ${startTimeRaw.runtimeType}');
      }

      // Calculate duration
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inSeconds;

      debugPrint('📊 Session duration: ${Duration(seconds: duration)}');

      // ✅ FIX: Use explicit Timestamp instead of FieldValue.serverTimestamp()
      final now = Timestamp.fromDate(DateTime.now());
      final endTimestamp = Timestamp.fromDate(endTime);

      // Use batch for atomic operation
      final batch = FirebaseFirestore.instance.batch();

      // 1. Update session with end details - map LocationData correctly
      batch.update(sessionRef, {
        'endTime': endTimestamp, // ✅ Use explicit timestamp
        'endLatitude': location.latitude,
        'endLongitude': location.longitude,
        'endAccuracy': location.accuracy,
        'endAddress':
            location.address ?? '${location.latitude}, ${location.longitude}',
        'endLocationTimestamp': Timestamp.fromDate(location.timestamp),
        'duration': duration,
        'updatedAt': now, // ✅ Use explicit timestamp
        'notes': notes ?? sessionData['notes'] ?? 'Shift ended via mobile app',
      });

      // 2. Update user duty status - can still use FieldValue.serverTimestamp() here
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      batch.update(userRef, {
        'isOnDuty': false,
        'currentSessionId': null,
        'lastStatusChange':
            FieldValue.serverTimestamp(), // This is fine for user doc
      });

      // Execute batch
      await batch.commit();

      debugPrint('✅ Shift ended successfully');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to end shift: $e');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Debug current state
  Future<void> debugCurrentState() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ No authenticated user');
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint('❌ User document not found');
        return;
      }

      final userData = userDoc.data()!;
      debugPrint('🔍 User state:');
      debugPrint('  - isOnDuty: ${userData['isOnDuty']}');
      debugPrint('  - currentSessionId: ${userData['currentSessionId']}');

      final sessionId = userData['currentSessionId'] as String?;
      if (sessionId != null) {
        final sessionDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('workHistory')
            .doc(sessionId)
            .get();

        if (sessionDoc.exists) {
          final sessionData = sessionDoc.data()!;
          debugPrint('🔍 Session state:');
          debugPrint('  - startTime: ${sessionData['startTime']}');
          debugPrint('  - endTime: ${sessionData['endTime']}');
          debugPrint('  - duration: ${sessionData['duration']}');
        }
      }
    } catch (e) {
      debugPrint('❌ Debug error: $e');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// 📋 CONVENIENCE PROVIDERS
// ═══════════════════════════════════════════════════════════════════

/// Recent work history (last 30 days)
final recentWorkHistoryProvider =
    Provider<AsyncValue<List<WorkSession>>>((ref) {
  final params = WorkHistoryParams(
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    limit: 50,
  );
  return ref.watch(workHistoryStreamProvider(params));
});

/// This week's work sessions
final thisWeekWorkHistoryProvider =
    Provider<AsyncValue<List<WorkSession>>>((ref) {
  final now = DateTime.now();
  final startOfWeek =
      DateTime(now.year, now.month, now.day - (now.weekday - 1));

  final params = WorkHistoryParams(
    startDate: startOfWeek,
    endDate: startOfWeek.add(const Duration(days: 7)),
    limit: 20,
  );
  return ref.watch(workHistoryStreamProvider(params));
});

/// Today's work sessions
final todayWorkHistoryProvider = Provider<AsyncValue<List<WorkSession>>>((ref) {
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  final params = WorkHistoryParams(
    startDate: startOfDay,
    endDate: endOfDay,
    limit: 20,
  );

  return ref.watch(workHistoryStreamProvider(params));
});

/// Current week's total hours - returns AsyncValue for .when() usage
final weeklyHoursProvider = Provider<AsyncValue<Duration>>((ref) {
  final sessionsAsync = ref.watch(thisWeekWorkHistoryProvider);

  return sessionsAsync.when(
    data: (sessions) {
      int totalSeconds = 0;
      final now = DateTime.now();

      for (final session in sessions) {
        if (session.duration != null) {
          // Completed session
          totalSeconds += session.duration!;
        } else if (session.endTime == null) {
          // Active session - calculate current duration
          final currentDuration = now.difference(session.startTime);
          totalSeconds += currentDuration.inSeconds;
        }
      }
      return AsyncValue.data(Duration(seconds: totalSeconds));
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Simple helper to check if user is currently on duty
final isOnDutyProvider = Provider<bool>((ref) {
  final currentSession = ref.watch(currentWorkSessionStreamProvider);
  return currentSession.when(
    data: (session) => session != null,
    loading: () => false,
    error: (_, __) => false,
  );
});
