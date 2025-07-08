// lib/shared/widgets/app_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/nav_icon.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  /// Route paths for each tab in order
  static const tabs = [
    '/tasks',
    '/schedule',
    '/patients',
    '/profile',
    '/admin'
  ];

  /// Get index of active tab based on current route
  int _indexForLocation(String location) {
    // Match full route or prefix
    for (int i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i])) return i;
    }
    return 0; // default to tasks
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      key: const ValueKey('app-shell'), // 🔑 for test targeting
      body: SafeArea(child: child),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            if (index != currentIndex) context.go(tabs[index]);
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: NavIcon(icon: Icons.list_alt_outlined, isSelected: false),
              activeIcon: NavIcon(icon: Icons.list_alt, isSelected: true),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: NavIcon(
                  icon: Icons.calendar_today_outlined, isSelected: false),
              activeIcon: NavIcon(icon: Icons.calendar_today, isSelected: true),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: NavIcon(icon: Icons.group, isSelected: false),
              activeIcon: NavIcon(icon: Icons.group, isSelected: true),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: NavIcon(icon: Icons.person, isSelected: false),
              activeIcon: NavIcon(icon: Icons.person, isSelected: true),
              label: '',
            ),
            // 🚨 Temporary Admin Portal Tab
            BottomNavigationBarItem(
              icon: NavIcon(
                  icon: Icons.admin_panel_settings_outlined, isSelected: false),
              activeIcon:
                  NavIcon(icon: Icons.admin_panel_settings, isSelected: true),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
