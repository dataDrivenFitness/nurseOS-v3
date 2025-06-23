import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/app.dart';
import 'mock/mock_patient_overrides.dart';

void main() {
  group('💡 NurseOS base shell renders', () {
    testWidgets('displays Assigned Patients screen with bottom navigation',
        (tester) async {
      // Run app with mock patient loading state
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mockPatientsLoading,
          ],
          child: const NurseOSApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Confirm nav bar widget exists
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is BottomNavigationBar ||
              w.runtimeType.toString() == 'NavigationBar',
        ),
        findsOneWidget,
      );

      // Confirm screen title is visible
      expect(find.text('Assigned Patients'), findsOneWidget);
    });
  });
}
