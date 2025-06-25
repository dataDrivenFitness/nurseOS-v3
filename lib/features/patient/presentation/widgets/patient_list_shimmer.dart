import 'package:flutter/material.dart';
import 'package:nurseos_v3/shared/widgets/shimmer/nurse_shimmer.dart';

class PatientListShimmer extends StatelessWidget {
  const PatientListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => const NurseShimmerCard(height: 96),
    );
  }
}
