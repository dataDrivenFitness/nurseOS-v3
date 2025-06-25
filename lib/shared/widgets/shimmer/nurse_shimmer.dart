import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NurseShimmerContainer extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const NurseShimmerContainer({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surface;
    final highlightColor = theme.colorScheme.surfaceVariant.withOpacity(0.5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class NurseShimmerLine extends StatelessWidget {
  final double width;
  final double height;

  const NurseShimmerLine({
    super.key,
    this.width = double.infinity,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    return NurseShimmerContainer(height: height, width: width);
  }
}

class NurseShimmerCard extends StatelessWidget {
  final double height;

  const NurseShimmerCard({
    super.key,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NurseShimmerContainer(
        height: height,
        width: double.infinity,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
