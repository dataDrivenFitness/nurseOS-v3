// 📁 lib/features/work_history/data/work_history_repository_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurseos_v3/core/env/env.dart';
import 'package:nurseos_v3/features/work_history/data/work_history_repository.dart';

/// Provider for work history repository
/// Switches between mock and Firebase implementation based on environment
final workHistoryRepositoryProvider = Provider<WorkHistoryRepository>((ref) {
  if (useMockServices) {
    return MockWorkHistoryRepository();
  }

  return FirebaseWorkHistoryRepository(FirebaseFirestore.instance);
});
