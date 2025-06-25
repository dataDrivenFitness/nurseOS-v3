import 'package:flutter/material.dart';

class NurseScaffold extends StatelessWidget {
  final Widget child;
  final bool safeArea;
  final Widget? bottomNav;

  const NurseScaffold({
    super.key,
    required this.child,
    this.safeArea = true,
    this.bottomNav,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = Column(
      children: [
        Expanded(child: child),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: safeArea ? SafeArea(child: scaffold) : scaffold,
      bottomNavigationBar: bottomNav,
    );
  }
}
