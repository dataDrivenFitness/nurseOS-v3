import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/env/env.dart';
import 'package:nurseos_v3/features/auth/services/abstract_auth_service.dart';
import 'package:nurseos_v3/features/auth/services/mock_auth_service.dart';
import 'package:nurseos_v3/features/auth/services/firebase_auth_service.dart';

/// Provides an instance of [AbstractAuthService], selecting between
/// mock and real Firebase implementations based on [useMockServices] env flag.
final authServiceProvider = Provider<AbstractAuthService>((ref) {
  if (useMockServices) {
    return MockAuthService(); // or provide a preloaded user if needed
  } else {
    return FirebaseAuthService();
  }
});
