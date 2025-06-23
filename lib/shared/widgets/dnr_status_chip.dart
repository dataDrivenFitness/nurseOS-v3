import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';

enum DnrStatus { fullCode, dnr, comfortCare }

class DnrStatusChip extends StatelessWidget {
  final DnrStatus status;

  const DnrStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      DnrStatus.fullCode => Colors.blueGrey,
      DnrStatus.dnr => Colors.deepPurple,
      DnrStatus.comfortCare => Colors.teal,
    };

    final label = switch (status) {
      DnrStatus.fullCode => 'Full Code',
      DnrStatus.dnr => 'DNR',
      DnrStatus.comfortCare => 'Comfort Care',
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withAlpha(AppAlpha.softLabel),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
