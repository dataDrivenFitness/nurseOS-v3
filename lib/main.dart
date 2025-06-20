import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/bootstrap.dart';

void main() {
  runApp(const ProviderScope(child: NurseOSApp()));
}

class NurseOSApp extends StatelessWidget {
  const NurseOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: createRouter(),
      title: 'NurseOS v3',
      theme: ThemeData.dark(), // we'll refactor with AppTheme later
    );
  }
}
