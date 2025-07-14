// lib/shared/widgets/app_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/core/providers/feature_flag_provider.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useNewNavigation = ref.watch(featureFlagProvider('navigation_v3'));

    if (useNewNavigation) {
      return _buildNewNavigation(context);
    } else {
      return _buildCurrentNavigation(context);
    }
  }

  Widget _buildNewNavigation(BuildContext context) {
    // New 4-tab navigation using proper GoRouter routes
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _getNewNavigationIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/available-shifts');
              break;
            case 1:
              context.go('/my-shift');
              break;
            case 2:
              context.go('/profile');
              break;
            case 3:
              context.go('/admin');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Available Shifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'My Shift',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentNavigation(BuildContext context) {
    // Current 5-tab navigation (original behavior)
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _getCurrentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/tasks');
              break;
            case 1:
              context.go('/schedule');
              break;
            case 2:
              context.go('/patients');
              break;
            case 3:
              context.go('/profile');
              break;
            case 4:
              context.go('/admin');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }

  int _getNewNavigationIndex(String location) {
    if (location.startsWith('/available-shifts')) return 0;
    if (location.startsWith('/my-shift')) return 1;
    if (location.startsWith('/profile')) return 2;
    if (location.startsWith('/admin')) return 3;
    return 0; // Default to Available Shifts
  }

  int _getCurrentIndex(String location) {
    if (location.startsWith('/tasks')) return 0;
    if (location.startsWith('/schedule')) return 1;
    if (location.startsWith('/patients')) return 2;
    if (location.startsWith('/profile')) return 3;
    if (location.startsWith('/admin')) return 4;
    return 0;
  }
}
