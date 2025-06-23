import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/patient_card.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/utils/risk_utils.dart';

Patient makeStubPatient({required RiskLevel riskLevel}) {
  return Patient(
    id: 'test-id',
    firstName: 'Test',
    lastName: 'Patient',
    location: 'Room 101',
    admittedAt: DateTime.now(),
    createdAt: DateTime.now(),
    primaryDiagnosis: 'Hypertension', // ✅ Ensure this is always passed
    manualRiskOverride: riskLevel,
  );
}

void main() {
  for (final risk in RiskLevel.values.where((r) => r != RiskLevel.unknown)) {
    testWidgets('PatientCard - ${risk.name}', (tester) async {
      final patient = makeStubPatient(riskLevel: risk);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: PatientCard(patient: patient),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(PatientCard),
        matchesGoldenFile('test/goldens/patient_card_${risk.name}.png'),
      );
    });
  }
}
