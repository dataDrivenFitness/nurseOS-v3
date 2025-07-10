import 'dart:async';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/features/agency/models/agency_role_model.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'abstract_auth_service.dart';

class MockAuthService implements AbstractAuthService {
  final _controller = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  MockAuthService({UserModel? user}) {
    if (user != null) {
      _currentUser = user;
      _controller.add(user);
    }
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final isAdmin = email.toLowerCase().contains('admin');

    final signedInUser = UserModel(
      uid: 'mock123',
      activeAgencyId: 'demo-agency',
      firstName: isAdmin ? 'Admin' : 'Mocky',
      lastName: isAdmin ? 'User' : 'Nurse',
      email: email,
      photoUrl: null,
      unit: 'demo-unit',
      createdAt: DateTime.now(),
      authProvider: 'mock',
      role: isAdmin ? UserRole.admin : UserRole.nurse,
      level: 1,
      xp: 0,
      badges: [],
      agencyRoles: {
        // Fixed: was 'agencyRoleMap', now 'agencyRoles'
        'demo-agency': AgencyRoleModel(
          agencyId: 'demo-agency',
          userId: 'mock123',
          role: isAdmin
              ? UserRole.admin
              : UserRole.nurse, // Fixed: now uses UserRole enum
          department: 'ICU', // Added department
          joinedAt: DateTime.now(),
        )
      },
    );

    _currentUser = signedInUser;
    _controller.add(_currentUser);

    return signedInUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Stream<UserModel?> get onAuthStateChanged => _controller.stream;

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }
}
