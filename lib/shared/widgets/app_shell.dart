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
    // New 5-tab Context-First Navigation Architecture
    // [Shifts] [Current] [Records] [Profile] [Admin]
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
              context.go('/shifts');
              break;
            case 1:
              context.go('/current');
              break;
            case 2:
              context.go('/records');
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
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Shifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'Current',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
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
    // Context-First Navigation mapping
    if (location.startsWith('/shifts')) return 0; // All shift management
    if (location.startsWith('/current')) return 1; // Active work session
    if (location.startsWith('/records')) return 2; // Work history & analytics
    if (location.startsWith('/profile')) return 3; // Personal information
    if (location.startsWith('/admin')) return 4; // System management

    // Legacy route compatibility during transition
    if (location.startsWith('/available-shifts'))
      return 0; // Redirect to Shifts
    if (location.startsWith('/my-shift')) return 1; // Redirect to Current

    return 0; // Default to Shifts tab
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
