// 📁 lib/features/work_history/data/work_history_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurseos_v3/features/work_history/models/work_session.dart';
import 'package:nurseos_v3/shared/models/location_data.dart';

abstract class WorkHistoryRepository {
  Future<String> startDutySession({
    required String userId,
    required LocationData location,
    String? department,
    String? shift,
    String? facility,
    String? notes,
  });

  Future<void> endDutySession({
    required String userId,
    required LocationData location,
    String? notes,
  });

  Future<WorkSession?> getCurrentSession(String userId);
  Future<bool> isUserOnDuty(String userId);
  Stream<List<WorkSession>> getWorkHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  Future<WorkSession?> getSession(String userId, String sessionId);
  Future<List<WorkSession>> getTodaysSessions(String userId);
  Future<Duration> getWeeklyHours(String userId, DateTime weekStart);
}

// ═══════════════════════════════════════════════════════════════════
// Firebase Implementation
// ═══════════════════════════════════════════════════════════════════

class FirebaseWorkHistoryRepository implements WorkHistoryRepository {
  final FirebaseFirestore _firestore;

  FirebaseWorkHistoryRepository(this._firestore);

  @override
  Future<String> startDutySession({
    required String userId,
    required LocationData location,
    String? department,
    String? shift,
    String? facility,
    String? notes,
  }) async {
    final now = DateTime.now();
    final sessionId =
        '${now.toIso8601String().split('T')[0]}_${now.millisecondsSinceEpoch}';

    final active = await getCurrentSession(userId);
    if (active != null) throw Exception('User already on duty');

    // ✅ Create WorkSession with correct field names
    final session = WorkSession(
      sessionId: sessionId,
      userId: userId,
      startTime: now,
      startLatitude: location.latitude,
      startLongitude: location.longitude,
      startAccuracy: location.accuracy,
      startAddress:
          location.address ?? '${location.latitude}, ${location.longitude}',
      startLocationTimestamp: location.timestamp,
      department: department,
      shift: shift,
      facility: facility,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    final batch = _firestore.batch();
    final sessionRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workHistory')
        .doc(sessionId);
    final userRef = _firestore.collection('users').doc(userId);

    batch.set(sessionRef, session.toJson());
    batch.update(userRef, {
      'isOnDuty': true,
      'currentSessionId': sessionId,
      'lastStatusChange': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return sessionId;
  }

  @override
  Future<void> endDutySession({
    required String userId,
    required LocationData location,
    String? notes,
  }) async {
    final session = await getCurrentSession(userId);
    if (session == null) throw Exception('No active session');

    final now = DateTime.now();
    final duration = now.difference(session.startTime).inSeconds;

    final sessionRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workHistory')
        .doc(session.sessionId);
    final userRef = _firestore.collection('users').doc(userId);

    final batch = _firestore.batch();

    batch.update(sessionRef, {
      'endTime': Timestamp.fromDate(now),
      'endLatitude': location.latitude,
      'endLongitude': location.longitude,
      'endAccuracy': location.accuracy,
      'endAddress':
          location.address ?? '${location.latitude}, ${location.longitude}',
      'endLocationTimestamp': Timestamp.fromDate(location.timestamp),
      'duration': duration,
      'updatedAt': FieldValue.serverTimestamp(),
      if (notes != null) 'notes': notes,
    });

    batch.update(userRef, {
      'isOnDuty': false,
      'currentSessionId': null,
      'lastStatusChange': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Future<WorkSession?> getCurrentSession(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final sessionId = doc.data()?['currentSessionId'] as String?;
    if (sessionId == null) return null;
    return getSession(userId, sessionId);
  }

  @override
  Future<bool> isUserOnDuty(String userId) async {
    return (await getCurrentSession(userId)) != null;
  }

  @override
  Stream<List<WorkSession>> getWorkHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('workHistory')
        .orderBy('startTime', descending: true)
        .limit(limit);

    if (startDate != null) {
      query = query.where('startTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('startTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query.snapshots().map((snap) => snap.docs
        .map((doc) {
          try {
            return WorkSession.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'sessionId': doc.id,
            });
          } catch (e) {
            print('❌ Error parsing session ${doc.id}: $e');
            return null;
          }
        })
        .whereType<WorkSession>()
        .toList());
  }

  @override
  Future<WorkSession?> getSession(String userId, String sessionId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workHistory')
        .doc(sessionId)
        .get();
    if (!doc.exists) return null;
    return WorkSession.fromJson({
      ...doc.data()!,
      'sessionId': doc.id,
    });
  }

  @override
  Future<List<WorkSession>> getTodaysSessions(String userId) async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workHistory')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startTime', isLessThan: Timestamp.fromDate(end))
        .orderBy('startTime')
        .get();

    return query.docs
        .map((doc) => WorkSession.fromJson({
              ...doc.data(),
              'sessionId': doc.id,
            }))
        .toList();
  }

  @override
  Future<Duration> getWeeklyHours(String userId, DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));

    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workHistory')
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .where('startTime', isLessThan: Timestamp.fromDate(weekEnd))
        .where('endTime', isNotEqualTo: null)
        .get();

    final total = query.docs.fold<int>(0, (sum, doc) {
      final duration = doc.data()['duration'];
      return duration is int ? sum + duration : sum;
    });

    return Duration(seconds: total);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Mock Implementation (for testing)
// ═══════════════════════════════════════════════════════════════════

class MockWorkHistoryRepository implements WorkHistoryRepository {
  final Map<String, List<WorkSession>> _sessions = {};
  final Map<String, String?> _currentSessions = {};

  @override
  Future<String> startDutySession({
    required String userId,
    required LocationData location,
    String? department,
    String? shift,
    String? facility,
    String? notes,
  }) async {
    if (_currentSessions[userId] != null) {
      throw Exception('User already has an active duty session');
    }

    final now = DateTime.now();
    final sessionId =
        '${now.toIso8601String().split('T')[0]}_${now.millisecondsSinceEpoch}';

    final session = WorkSession(
      sessionId: sessionId,
      userId: userId,
      startTime: now,
      startLatitude: location.latitude,
      startLongitude: location.longitude,
      startAccuracy: location.accuracy,
      startAddress:
          location.address ?? '${location.latitude}, ${location.longitude}',
      startLocationTimestamp: location.timestamp,
      department: department,
      shift: shift,
      facility: facility,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    _sessions[userId] = [...(_sessions[userId] ?? []), session];
    _currentSessions[userId] = sessionId;

    return sessionId;
  }

  @override
  Future<void> endDutySession({
    required String userId,
    required LocationData location,
    String? notes,
  }) async {
    final currentSessionId = _currentSessions[userId];
    if (currentSessionId == null) {
      throw Exception('No active session to end');
    }

    final sessions = _sessions[userId] ?? [];
    final sessionIndex =
        sessions.indexWhere((s) => s.sessionId == currentSessionId);

    if (sessionIndex == -1) {
      throw Exception('Session not found');
    }

    final endTime = DateTime.now();
    final session = sessions[sessionIndex];
    final duration = endTime.difference(session.startTime).inSeconds;

    final updatedSession = session.copyWith(
      endTime: endTime,
      endLatitude: location.latitude,
      endLongitude: location.longitude,
      endAccuracy: location.accuracy,
      endAddress:
          location.address ?? '${location.latitude}, ${location.longitude}',
      endLocationTimestamp: location.timestamp,
      duration: duration,
      updatedAt: DateTime.now(),
      notes: notes ?? session.notes,
    );

    sessions[sessionIndex] = updatedSession;
    _currentSessions[userId] = null;
  }

  @override
  Future<WorkSession?> getCurrentSession(String userId) async {
    final currentSessionId = _currentSessions[userId];
    if (currentSessionId == null) return null;
    return getSession(userId, currentSessionId);
  }

  @override
  Future<bool> isUserOnDuty(String userId) async {
    return _currentSessions[userId] != null;
  }

  @override
  Stream<List<WorkSession>> getWorkHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) {
    var sessions = _sessions[userId] ?? [];

    if (startDate != null) {
      sessions = sessions
          .where((s) =>
              s.startTime.isAfter(startDate) ||
              s.startTime.isAtSameMomentAs(startDate))
          .toList();
    }

    if (endDate != null) {
      sessions = sessions
          .where((s) =>
              s.startTime.isBefore(endDate) ||
              s.startTime.isAtSameMomentAs(endDate))
          .toList();
    }

    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));

    if (sessions.length > limit) {
      sessions = sessions.take(limit).toList();
    }

    return Stream.value(sessions);
  }

  @override
  Future<WorkSession?> getSession(String userId, String sessionId) async {
    final sessions = _sessions[userId] ?? [];
    try {
      return sessions.firstWhere((s) => s.sessionId == sessionId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<WorkSession>> getTodaysSessions(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final sessions = _sessions[userId] ?? [];
    return sessions
        .where((s) =>
            s.startTime.isAfter(startOfDay) && s.startTime.isBefore(endOfDay))
        .toList();
  }

  @override
  Future<Duration> getWeeklyHours(String userId, DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final sessions = _sessions[userId] ?? [];

    int totalSeconds = 0;
    for (final session in sessions) {
      if (session.startTime.isAfter(weekStart) &&
          session.startTime.isBefore(weekEnd) &&
          session.duration != null) {
        totalSeconds += session.duration!;
      }
    }

    return Duration(seconds: totalSeconds);
  }
}
