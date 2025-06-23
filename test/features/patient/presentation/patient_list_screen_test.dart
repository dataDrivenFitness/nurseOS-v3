import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurseos_v3/features/patient/presentation/patient_list_screen.dart';
import 'package:nurseos_v3/shared/widgets/loading/patient_list_shimmer.dart';
import 'package:nurseos_v3/shared/widgets/error/error_retry_tile.dart';

import '../../../mock/mock_patient_overrides.dart';

void main() {
  testWidgets('shows shimmer while loading', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mockPatientsLoading],
        child: const MaterialApp(home: PatientListScreen()),
      ),
    );

    // *NO* extra pump – UI is already in the first frame
    expect(find.byType(PatientListShimmer), findsOneWidget);
  });

  testWidgets('shows error tile on failure', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mockPatientsError],
        child: const MaterialApp(home: PatientListScreen()),
      ),
    );

    expect(find.byType(ErrorRetryTile), findsOneWidget);
    expect(find.textContaining('Failed'), findsOneWidget);
  });

  testWidgets('shows empty-state text when list is empty', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mockPatientsEmpty],
        child: const MaterialApp(home: PatientListScreen()),
      ),
    );

    expect(find.text('No patients assigned.'), findsOneWidget);
  });
}
