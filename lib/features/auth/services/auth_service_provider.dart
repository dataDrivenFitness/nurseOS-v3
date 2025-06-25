// lib/features/auth/services/auth_service_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/env/env.dart';
import 'package:nurseos_v3/features/auth/services/abstract_auth_service.dart';
import 'package:nurseos_v3/features/auth/services/mock_auth_service.dart';
import 'package:nurseos_v3/features/auth/services/firebase_auth_service.dart';

/// Global provider that switches between mock and Firebase Auth
/// based on `.env` flag `useMockServices`
///
/// This controls both `signIn` and `getCurrentUser` behavior
final authServiceProvider = Provider<AbstractAuthService>((ref) {
  if (useMockServices) {
    return MockAuthService();
  } else {
    return FirebaseAuthService();
  }
});
