import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nurseos_v3/main.dart';

void main() {
  testWidgets('App builds and renders base shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NurseOSApp()),
    );

    // Basic sanity check: app renders something expected from AppShell
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
