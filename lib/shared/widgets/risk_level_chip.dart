import 'package:flutter/material.dart';
import 'package:nurseos_v3/features/patient/models/patient_risk.dart';

class RiskLevelChip extends StatelessWidget {
  final RiskLevel risk;

  const RiskLevelChip({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    final label = switch (risk) {
      RiskLevel.low => 'Low',
      RiskLevel.medium => 'Medium',
      RiskLevel.high => 'High',
      RiskLevel.unknown => 'Unknown',
    };

    final color = switch (risk) {
      RiskLevel.low => Colors.green,
      RiskLevel.medium => Colors.orange,
      RiskLevel.high => Colors.red,
      RiskLevel.unknown => Colors.grey,
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withAlpha(30),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
