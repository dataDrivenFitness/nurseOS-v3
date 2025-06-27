import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/abstract_xp_repository.dart';
import '../services/mock_xp_repository.dart';
import '../services/firebase_xp_repository.dart';
import 'package:nurseos_v3/core/env/env.dart'; // contains useMockServices

/// XP Repository provider — switches between mock and Firebase based on .env
final xpRepositoryProvider = Provider<AbstractXpRepository>((ref) {
  if (useMockServices) {
    return MockXpRepository();
  } else {
    return FirebaseXpRepository();
  }
});
