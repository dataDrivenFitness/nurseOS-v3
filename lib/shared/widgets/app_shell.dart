import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/nav_icon.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  // Routes for each tab
  static const tabs = ['/tasks', '/patients', '/profile'];

  /// Returns the index that matches the current location.
  int _indexForLocation(String location) =>
      tabs.indexWhere(location.startsWith).clamp(0, tabs.length - 1);

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      key: const ValueKey('app-shell'), // 🔑 let tests target *this* Scaffold
      body: SafeArea(child: child),

      // --- bottom navigation -------------------------------------------------
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
              icon: NavIcon(icon: Icons.group_outlined, isSelected: false),
              activeIcon: NavIcon(icon: Icons.group, isSelected: true),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: NavIcon(icon: Icons.person_outline, isSelected: false),
              activeIcon: NavIcon(icon: Icons.person, isSelected: true),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
