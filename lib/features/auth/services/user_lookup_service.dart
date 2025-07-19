// 📁 lib/features/auth/services/user_lookup_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_lookup_service.g.dart';

/// Service for looking up user names by ID
///
/// ✅ COLLEAGUE EMPATHY: Converts requestingNurseId to "Help Sarah"
/// ✅ Performance optimized with in-memory caching
/// ✅ Follows NurseOS architectural patterns
/// ✅ Supports both mock and live Firebase modes
abstract class UserLookupService {
  /// Get display name for a user by their ID
  /// Returns null if user not found or on error
  Future<String?> getUserDisplayName(String userId);

  /// Get first name only for informal display
  /// Returns null if user not found or on error
  Future<String?> getUserFirstName(String userId);

  /// Batch lookup for multiple users (performance optimization)
  Future<Map<String, String>> getUserDisplayNames(List<String> userIds);

  /// Clear the cache (useful for testing or memory management)
  void clearCache();
}

/// Firebase implementation of UserLookupService
class FirebaseUserLookupService implements UserLookupService {
  final FirebaseFirestore _db;
  final Map<String, String> _displayNameCache = {};
  final Map<String, String> _firstNameCache = {};

  FirebaseUserLookupService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String?> getUserDisplayName(String userId) async {
    // Check cache first
    if (_displayNameCache.containsKey(userId)) {
      return _displayNameCache[userId];
    }

    try {
      final doc = await _db.collection('users').doc(userId).get();

      if (!doc.exists) {
        debugPrint('⚠️ UserLookup: User not found for ID: $userId');
        return null;
      }

      final data = doc.data();
      if (data == null) {
        debugPrint('⚠️ UserLookup: No data for user ID: $userId');
        return null;
      }

      final firstName = data['firstName'] as String?;
      final lastName = data['lastName'] as String?;

      if (firstName == null) {
        debugPrint('⚠️ UserLookup: No firstName for user ID: $userId');
        return null;
      }

      // Create display name: "Sarah Johnson"
      final displayName = lastName != null ? '$firstName $lastName' : firstName;

      // Cache the result
      _displayNameCache[userId] = displayName;
      _firstNameCache[userId] = firstName;

      debugPrint('✅ UserLookup: Resolved $userId -> $displayName');
      return displayName;
    } catch (e) {
      debugPrint('🛑 UserLookup: Error fetching user $userId: $e');
      return null;
    }
  }

  @override
  Future<String?> getUserFirstName(String userId) async {
    // Check cache first
    if (_firstNameCache.containsKey(userId)) {
      return _firstNameCache[userId];
    }

    // If we have display name cached, extract first name
    if (_displayNameCache.containsKey(userId)) {
      final displayName = _displayNameCache[userId]!;
      final firstName = displayName.split(' ').first;
      _firstNameCache[userId] = firstName;
      return firstName;
    }

    // Otherwise, fetch full user data
    await getUserDisplayName(userId);
    return _firstNameCache[userId];
  }

  @override
  Future<Map<String, String>> getUserDisplayNames(List<String> userIds) async {
    final result = <String, String>{};
    final uncachedIds = <String>[];

    // Check cache for each user
    for (final userId in userIds) {
      if (_displayNameCache.containsKey(userId)) {
        result[userId] = _displayNameCache[userId]!;
      } else {
        uncachedIds.add(userId);
      }
    }

    // Batch fetch uncached users
    if (uncachedIds.isNotEmpty) {
      try {
        final futures =
            uncachedIds.map((id) => _db.collection('users').doc(id).get());

        final docs = await Future.wait(futures);

        for (int i = 0; i < docs.length; i++) {
          final doc = docs[i];
          final userId = uncachedIds[i];

          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            final firstName = data['firstName'] as String?;
            final lastName = data['lastName'] as String?;

            if (firstName != null) {
              final displayName =
                  lastName != null ? '$firstName $lastName' : firstName;

              _displayNameCache[userId] = displayName;
              _firstNameCache[userId] = firstName;
              result[userId] = displayName;
            }
          }
        }

        debugPrint(
            '✅ UserLookup: Batch resolved ${result.length}/${userIds.length} users');
      } catch (e) {
        debugPrint('🛑 UserLookup: Batch fetch error: $e');
      }
    }

    return result;
  }

  @override
  void clearCache() {
    _displayNameCache.clear();
    _firstNameCache.clear();
    debugPrint('🧹 UserLookup: Cache cleared');
  }
}

/// Mock implementation for testing and development
class MockUserLookupService implements UserLookupService {
  final Map<String, String> _mockUsers = {
    'nurse1': 'Sarah Johnson',
    'nurse2': 'Michael Chen',
    'nurse3': 'Emma Rodriguez',
    'nurse4': 'David Kim',
    'nurse5': 'Lisa Thompson',
    'requesting_nurse_1': 'Jessica Martinez',
    'requesting_nurse_2': 'Robert Williams',
  };

  @override
  Future<String?> getUserDisplayName(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    final name = _mockUsers[userId];
    if (name != null) {
      debugPrint('✅ MockUserLookup: Resolved $userId -> $name');
    } else {
      debugPrint('⚠️ MockUserLookup: User not found for ID: $userId');
    }
    return name;
  }

  @override
  Future<String?> getUserFirstName(String userId) async {
    final displayName = await getUserDisplayName(userId);
    return displayName?.split(' ').first;
  }

  @override
  Future<Map<String, String>> getUserDisplayNames(List<String> userIds) async {
    final result = <String, String>{};

    for (final userId in userIds) {
      final name = await getUserDisplayName(userId);
      if (name != null) {
        result[userId] = name;
      }
    }

    return result;
  }

  @override
  void clearCache() {
    debugPrint('🧹 MockUserLookup: Cache cleared (no-op)');
  }
}

/// Riverpod provider for UserLookupService
///
/// ✅ Supports both mock and live modes
/// ✅ Singleton pattern for caching efficiency
@Riverpod(keepAlive: true)
UserLookupService userLookupService(UserLookupServiceRef ref) {
  // TODO: Add environment check for mock vs live
  // For now, defaulting to Firebase (can be overridden in tests)
  const bool useMockData =
      bool.fromEnvironment('USE_MOCK_DATA', defaultValue: false);

  if (useMockData) {
    debugPrint('🎭 UserLookup: Using mock service');
    return MockUserLookupService();
  } else {
    debugPrint('🔥 UserLookup: Using Firebase service');
    return FirebaseUserLookupService();
  }
}

/// Helper provider for getting user first names specifically for colleague empathy
@riverpod
Future<String?> userFirstName(UserFirstNameRef ref, String userId) async {
  final service = ref.watch(userLookupServiceProvider);
  return await service.getUserFirstName(userId);
}
