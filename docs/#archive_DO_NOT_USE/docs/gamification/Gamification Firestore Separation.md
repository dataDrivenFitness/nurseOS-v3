# Complete Gamification Firestore Separation Documentation

## Overview
This document provides step-by-step instructions for separating gamification data from user professional data in NurseOS, creating true Firestore collection separation while avoiding any code duplication.

## Current Architecture Analysis

### Existing Files (Do NOT Duplicate)
```
lib/features/gamification/
├── services/
│   ├── abstract_xp_repository.dart      ✅ EXTEND (add badge methods)
│   ├── firebase_xp_repository.dart      ✅ EXTEND (implement badge methods)
│   └── mock_xp_repository.dart          ✅ EXTEND (implement badge methods)
├── state/
│   └── xp_repository.dart               ✅ KEEP (provider works perfectly)
```

### Current Firestore Structure
```
users/{uid}
├── firstName, lastName, email, role     // Professional identity
├── xp: int, level: int                  // ← MOVE to gamification/
└── badges/{badgeId}                     // ← MOVE to gamification/
    └── awardedAt: timestamp

leaderboards/                            // ← KEEP as-is
└── weekly/{weekId}/{uid}: {xp: int}
```

### Target Firestore Structure
```
users/{uid}                              // Professional identity only
├── firstName: "Carolyn"
├── lastName: "Davis"
├── email: "carolyn@hospital.com"
├── role: "nurse"
├── department: "ICU"                    // ← NEW healthcare fields
├── shift: "night"
├── phoneExtension: "4521"
├── licenseNumber: "RN123456"
├── licenseExpiry: timestamp
├── specialty: "Critical Care"
├── certifications: ["BLS", "ACLS"]
└── isOnDuty: true

gamification/{uid}                       // ← NEW collection
├── level: 5
├── totalXp: 1240
├── weeklyXp: 85
├── monthlyXp: 320
├── currentStreak: 12
├── longestStreak: 45
├── lastActivityDate: timestamp
├── recentEvents: [...]                  // XP gain history
├── achievementProgress: {...}
├── createdAt: timestamp
├── updatedAt: timestamp
└── badges/{badgeId}                     // ← MOVED from users/
    └── awardedAt: timestamp

leaderboards/                            // ← UNCHANGED
└── weekly/{weekId}/{uid}: {xp: int}
```

## Implementation Plan

### Phase 1: Extend Existing Repository Interface

#### 1.1 Update AbstractXpRepository
```dart
// lib/features/gamification/services/abstract_xp_repository.dart
abstract class AbstractXpRepository {
  // ✅ KEEP existing methods (no breaking changes)
  Future<int> getXp(String userId);
  Future<void> incrementXp(String userId, {int amount = 1});
  
  // 🆕 ADD badge methods only
  Future<List<String>> getBadges(String userId);
  Future<void> awardBadge(String userId, String badgeId);
}
```

#### 1.2 Extend FirebaseXpRepository
```dart
// lib/features/gamification/services/firebase_xp_repository.dart
class FirebaseXpRepository implements AbstractXpRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ KEEP existing XP methods unchanged
  @override
  Future<int> getXp(String userId) async {
    // During migration: read from new location, fallback to old
    final gamificationDoc = await _db.collection('gamification').doc(userId).get();
    if (gamificationDoc.exists) {
      return gamificationDoc.data()?['totalXp'] ?? 0;
    }
    
    // Fallback to old location
    final userDoc = await _db.collection('users').doc(userId).get();
    return userDoc.data()?['xp'] ?? 0;
  }

  @override
  Future<void> incrementXp(String userId, {int amount = 1}) async {
    // During migration: write to new location only
    final gamificationRef = _db.collection('gamification').doc(userId);
    
    await _db.runTransaction((txn) async {
      final snapshot = await txn.get(gamificationRef);
      
      if (!snapshot.exists) {
        // Create initial gamification profile
        final newProfile = {
          'userId': userId,
          'totalXp': amount,
          'level': 1,
          'weeklyXp': amount,
          'monthlyXp': amount,
          'currentStreak': 1,
          'longestStreak': 1,
          'lastActivityDate': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        txn.set(gamificationRef, newProfile);
      } else {
        final current = (snapshot.data()?['totalXp'] ?? 0) as int;
        final newTotal = current + amount;
        final newLevel = (newTotal / 100).floor() + 1;
        
        txn.update(gamificationRef, {
          'totalXp': newTotal,
          'level': newLevel,
          'lastActivityDate': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // 🆕 ADD badge methods (new location)
  @override
  Future<List<String>> getBadges(String userId) async {
    final badgesQuery = await _db
        .collection('gamification')
        .doc(userId)
        .collection('badges')
        .get();
    return badgesQuery.docs.map((doc) => doc.id).toList();
  }

  @override
  Future<void> awardBadge(String userId, String badgeId) async {
    await _db
        .collection('gamification')
        .doc(userId)
        .collection('badges')
        .doc(badgeId)
        .set({'awardedAt': FieldValue.serverTimestamp()});
  }
}
```

#### 1.3 Extend MockXpRepository
```dart
// lib/features/gamification/services/mock_xp_repository.dart
class MockXpRepository implements AbstractXpRepository {
  final _mockXp = HashMap<String, int>();
  final _mockBadges = HashMap<String, List<String>>();

  // ✅ KEEP existing methods unchanged
  @override
  Future<int> getXp(String userId) async => _mockXp[userId] ?? 0;

  @override
  Future<void> incrementXp(String userId, {int amount = 1}) async {
    final current = _mockXp[userId] ?? 0;
    _mockXp[userId] = current + amount;
  }

  // 🆕 ADD badge methods
  @override
  Future<List<String>> getBadges(String userId) async => _mockBadges[userId] ?? [];

  @override
  Future<void> awardBadge(String userId, String badgeId) async {
    final current = _mockBadges[userId] ?? [];
    if (!current.contains(badgeId)) {
      _mockBadges[userId] = [...current, badgeId];
    }
  }
}
```

### Phase 2: Create New Models

#### 2.1 GamificationProfile Model
```dart
// lib/features/gamification/models/gamification_profile.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'gamification_profile.freezed.dart';
part 'gamification_profile.g.dart';

@freezed
abstract class GamificationProfile with _$GamificationProfile {
  const factory GamificationProfile({
    required String userId,
    @Default(1) int level,
    @Default(0) int totalXp,
    @Default(0) int weeklyXp,
    @Default(0) int monthlyXp,
    @Default([]) List<String> badges,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @TimestampConverter() DateTime? lastActivityDate,
    @Default({}) Map<String, int> achievementProgress,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _GamificationProfile;

  factory GamificationProfile.fromJson(Map<String, dynamic> json) =>
      _$GamificationProfileFromJson(json);
      
  // Helper computed properties
  const GamificationProfile._();
  
  int get xpForCurrentLevel => (level - 1) * 100;
  int get xpForNextLevel => level * 100;
  int get xpProgress => totalXp - xpForCurrentLevel;
  double get progressPercent => xpProgress / 100.0;
  bool get hasRecentActivity => lastActivityDate != null && 
    DateTime.now().difference(lastActivityDate!).inDays < 7;
}
```

#### 2.2 Update UserModel (Add Healthcare Fields)
```dart
// lib/features/auth/models/user_model.dart
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    // ✅ KEEP existing core fields
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    String? photoUrl,
    String? unit,
    @TimestampConverter() DateTime? createdAt,
    String? authProvider,
    @UserRoleConverter() required UserRole role,
    
    // 🆕 ADD healthcare professional fields
    String? licenseNumber,
    @TimestampConverter() DateTime? licenseExpiry,
    String? specialty,           // ICU, Med-Surg, ER, etc.
    String? department,          // More specific than unit
    String? shift,              // Day, Night, Evening
    String? phoneExtension,     // Internal hospital extension
    @TimestampConverter() DateTime? hireDate,
    List<String>? certifications, // BLS, ACLS, PALS, etc.
    bool? isOnDuty,            // Current shift status
    
    // ⚠️ MIGRATION SUPPORT - Remove these after migration complete
    @Default(1) int level,       // DEPRECATED - will be removed
    @Default(0) int xp,          // DEPRECATED - will be removed  
    @Default([]) List<String> badges, // DEPRECATED - will be removed
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

### Phase 3: Create Gamification Controller

#### 3.1 GamificationController
```dart
// lib/features/gamification/state/gamification_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gamification_profile.dart';
import '../../auth/state/auth_controller.dart';
import '../state/xp_repository.dart';

class GamificationController extends AsyncNotifier<GamificationProfile?> {
  @override
  Future<GamificationProfile?> build() async {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) return null;

    return _fetchGamificationProfile(user.uid);
  }

  Future<GamificationProfile?> _fetchGamificationProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('gamification')
          .doc(userId)
          .withConverter<GamificationProfile>(
            fromFirestore: (snap, _) => GamificationProfile.fromJson(snap.data()!),
            toFirestore: (profile, _) => profile.toJson(),
          )
          .get();

      if (!doc.exists) {
        // Create initial profile if doesn't exist
        final xpRepo = ref.read(xpRepositoryProvider);
        final xp = await xpRepo.getXp(userId);
        final badges = await xpRepo.getBadges(userId);
        
        final newProfile = GamificationProfile(
          userId: userId,
          totalXp: xp,
          level: (xp / 100).floor() + 1,
          badges: badges,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await doc.reference.set(newProfile);
        return newProfile;
      }

      return doc.data();
    } catch (e) {
      throw Exception('Failed to fetch gamification profile: $e');
    }
  }

  Future<void> incrementXp({int amount = 1}) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;
    
    // Use existing XP repository (which now writes to new location)
    final xpRepo = ref.read(xpRepositoryProvider);
    await xpRepo.incrementXp(user.uid, amount: amount);
    
    // Refresh the profile
    ref.invalidateSelf();
  }

  Future<void> awardBadge(String badgeId) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;
    
    final xpRepo = ref.read(xpRepositoryProvider);
    await xpRepo.awardBadge(user.uid, badgeId);
    
    ref.invalidateSelf();
  }
}

final gamificationControllerProvider = AsyncNotifierProvider<GamificationController, GamificationProfile?>(
  () => GamificationController(),
);
```

### Phase 4: Data Migration Script

#### 4.1 Migration Service
```dart
// lib/features/gamification/services/migration_service.dart
class GamificationMigrationService {
  static Future<void> migrateUserGamificationData(String userId) async {
    final batch = FirebaseFirestore.instance.batch();
    
    try {
      // Check if already migrated
      final gamificationDoc = FirebaseFirestore.instance
          .collection('gamification')
          .doc(userId);
      
      final existingGamification = await gamificationDoc.get();
      if (existingGamification.exists) {
        print('✅ User $userId already migrated');
        return;
      }
      
      // Get user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (!userDoc.exists) {
        print('❌ User $userId not found');
        return;
      }
      
      final userData = userDoc.data()!;
      
      // Get badges from old location
      final oldBadgesQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('badges')
          .get();
      
      // Create gamification profile
      final gamificationProfile = {
        'userId': userId,
        'level': userData['level'] ?? 1,
        'totalXp': userData['xp'] ?? 0,
        'weeklyXp': 0, // Reset weekly counters
        'monthlyXp': 0, // Reset monthly counters
        'currentStreak': 0,
        'longestStreak': 0,
        'lastActivityDate': null,
        'achievementProgress': {},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Write gamification profile
      batch.set(gamificationDoc, gamificationProfile);
      
      // Migrate badges to new location
      for (final badgeDoc in oldBadgesQuery.docs) {
        final newBadgeRef = gamificationDoc
            .collection('badges')
            .doc(badgeDoc.id);
        batch.set(newBadgeRef, badgeDoc.data());
      }
      
      await batch.commit();
      print('✅ Successfully migrated user $userId');
      
    } catch (e) {
      print('❌ Migration failed for user $userId: $e');
      rethrow;
    }
  }
  
  static Future<void> migrateAllUsers() async {
    final usersQuery = await FirebaseFirestore.instance
        .collection('users')
        .get();
    
    int successCount = 0;
    int errorCount = 0;
    
    for (final doc in usersQuery.docs) {
      try {
        await migrateUserGamificationData(doc.id);
        successCount++;
      } catch (e) {
        errorCount++;
        print('❌ Failed to migrate ${doc.id}: $e');
      }
      
      // Progress logging
      if ((successCount + errorCount) % 10 == 0) {
        print('📊 Progress: $successCount migrated, $errorCount errors');
      }
    }
    
    print('🎉 Migration complete! $successCount migrated, $errorCount errors');
  }
}
```

### Phase 5: Update Profile UI

#### 5.1 Gamification Summary Widget
```dart
// lib/features/gamification/widgets/gamification_summary.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../state/gamification_controller.dart';

class GamificationSummary extends ConsumerWidget {
  const GamificationSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    
    return ref.watch(gamificationControllerProvider).when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.xs,
          ),
          decoration: BoxDecoration(
            color: colors.brandPrimary.withAlpha(26),
            borderRadius: BorderRadius.circular(SpacingTokens.xs),
          ),
          child: Text(
            'Level ${profile.level} • ${profile.totalXp} XP',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.brandPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 60,
        height: 20,
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

#### 5.2 Updated Profile Screen
Replace the identity section in profile_screen.dart:
```dart
// Compact Identity Header with Left-Right Layout
Row(
  children: [
    // Left: Avatar + Status
    Stack(
      children: [
        ProfileAvatar(
          photoUrl: user.photoUrl,
          fallbackName: '${user.firstName} ${user.lastName}',
          radius: 32,
          showBorder: true,
        ),
        // Duty status indicator
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: user.isOnDuty == true ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
            ),
          ),
        ),
      ],
    ),
    const SizedBox(width: SpacingTokens.md),
    // Right: Professional Identity
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${user.firstName} ${user.lastName}, RN',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
          if (user.department != null || user.shift != null)
            Text(
              '${user.department ?? ''} • ${user.shift ?? ''} Shift • Ext. ${user.phoneExtension ?? ''}',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.brandPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          const GamificationSummary(), // ← Uses new separated data
          Text(
            user.email,
            style: textTheme.bodySmall?.copyWith(color: colors.subdued),
          ),
        ],
      ),
    ),
  ],
)
```

## Deployment Timeline

### Week 1: Extend Repository
- ✅ Add badge methods to AbstractXpRepository
- ✅ Implement badge methods in Firebase/Mock repositories  
- ✅ Deploy with backward compatibility
- ✅ Test existing XP functionality still works

### Week 2: Add Models & Controller
- ✅ Create GamificationProfile model
- ✅ Create GamificationController
- ✅ Add healthcare fields to UserModel
- ✅ Deploy and test in staging

### Week 3: Migration
- ✅ Deploy migration script
- ✅ Run migration on production data
- ✅ Validate data integrity
- ✅ Monitor for any issues

### Week 4: UI Updates & Cleanup
- ✅ Update profile screen with compact layout
- ✅ Switch XP repository to read from new location
- ✅ Remove deprecated fields from UserModel (optional)

## Rollback Plan

If issues arise:
1. **Repository Rollback**: Revert FirebaseXpRepository to read from users/ collection
2. **UI Fallback**: Profile screen can fall back to UserModel XP fields
3. **Data Safety**: Original data in users/ collection remains untouched

## Success Metrics

- ✅ All users have gamification profiles in new collection
- ✅ XP gains continue working without interruption
- ✅ Profile screen loads faster (separate collections)
- ✅ Zero data loss during migration
- ✅ Healthcare fields properly displayed
- ✅ Gamification can be toggled independently

## Final File Structure

```
lib/features/
├── auth/models/user_model.dart           ← EXTENDED (healthcare fields)
├── gamification/
│   ├── models/gamification_profile.dart  ← NEW
│   ├── services/
│   │   ├── abstract_xp_repository.dart   ← EXTENDED (badge methods)
│   │   ├── firebase_xp_repository.dart   ← EXTENDED (new collection)
│   │   ├── mock_xp_repository.dart       ← EXTENDED (badge methods)
│   │   └── migration_service.dart        ← NEW
│   ├── state/
│   │   ├── xp_repository.dart            ← UNCHANGED
│   │   └── gamification_controller.dart  ← NEW
│   └── widgets/
│       └── gamification_summary.dart     ← NEW
└── profile/screens/profile_screen.dart   ← UPDATED (compact layout)
```

This approach achieves true Firestore separation while extending (not duplicating) your existing architecture!