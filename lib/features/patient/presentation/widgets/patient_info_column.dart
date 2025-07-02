import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/patient_extensions.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';

class PatientInfoColumn extends StatelessWidget {
  final Patient patient;
  final AppColors colors;
  final TextTheme textTheme;

  const PatientInfoColumn({
    super.key,
    required this.patient,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final tags = <String>[];
    final allergies = patient.allergies ?? [];

    // Add code status first if present
    final codeStatus = patient.codeStatus?.trim();
    if (codeStatus?.isNotEmpty == true) {
      tags.add(codeStatus!);
    }

    // Then add other risk tags
    final riskTags = patient.riskTags
        .where((t) => !t.toLowerCase().startsWith('risk:'))
        .toList();
    tags.addAll(riskTags);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 👤 Name + pronouns
        RichText(
          text: TextSpan(
            style: textTheme.titleMedium?.copyWith(color: colors.text),
            children: [
              TextSpan(text: patient.fullName),
              if (patient.pronouns?.trim().isNotEmpty == true)
                TextSpan(
                  text: ' (${patient.pronouns!.trim()})',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.subdued,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // 📋 Age · Sex · Language
        _buildLineWithIcon(
          icon: Icons.person,
          text: [
            if (patient.age != null) '${patient.age} yrs',
            patient.sexLabel,
            if (patient.language?.trim().isNotEmpty == true)
              patient.language!.trim(),
          ].join(' · '),
          textStyle: textTheme.bodySmall,
          color: colors.subdued,
        ),

        // 💉 Diagnosis
        _buildLineWithIcon(
          icon: Icons.medical_services,
          text: patient.primaryDiagnosis,
          textStyle: textTheme.bodySmall,
          color: colors.onSurface.withAlpha(140),
        ),

        // 📍 Location
        if (patient.location.trim().isNotEmpty)
          _buildLineWithIcon(
            icon: Icons.location_on,
            text: patient.location,
            textStyle: textTheme.bodySmall,
            color: colors.subdued,
          ),

        // 🍽️ Diet Restrictions
        if (patient.dietRestrictions != null &&
            patient.dietRestrictions!.isNotEmpty)
          _buildLineWithIcon(
            icon: Icons.restaurant_menu,
            text: patient.dietRestrictions!.join(', '),
            textStyle: textTheme.bodySmall,
            color: colors.brandAccent,
          ),

        // ⚠️ Allergies
        if (allergies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // 🔥 center alignment
              children: [
                SizedBox(
                  width: 16, // 🔥 consistent icon container width
                  height: (textTheme.labelSmall?.fontSize ?? 14) * 1.2,
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: (textTheme.labelSmall?.fontSize ?? 14).clamp(
                        12.0, 18.0), // 🔥 constrained responsive icon size
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    allergies.join(', '),
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 🏷️ Tags (including Fall Risk, Isolation, and Code Status)
        if (tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags
                  .map((tag) => GestureDetector(
                        onLongPress: () => _showTagInfo(context, tag),
                        child: _buildTagChip(tag),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    final tagLower = tag.toLowerCase();
    Color bg;
    Color fg;
    IconData? icon;

    // Determine styling based on tag type
    if (tagLower.contains('fall')) {
      bg = colors.warning.withAlpha(30);
      fg = colors.warning;
      icon = Icons.warning_amber_rounded;
    } else if (tagLower.contains('isolation')) {
      bg = colors.brandAccent.withAlpha(30);
      fg = colors.brandAccent;
      icon = Icons.security;
    } else if (_isCodeStatus(tagLower)) {
      // Code status styling
      switch (tagLower) {
        case 'dnr':
          bg = colors.danger.withOpacity(0.15);
          fg = colors.danger;
          icon = Icons.heart_broken;
          break;
        case 'dni':
          bg = colors.warning.withOpacity(0.15);
          fg = colors.warning;
          icon = Icons.remove_circle_outline;
          break;
        case 'full':
        case 'full code':
          bg = colors.success.withOpacity(0.15);
          fg = colors.success;
          icon = Icons.favorite;
          break;
        case 'limited':
          bg = colors.brandAccent.withOpacity(0.15);
          fg = colors.brandAccent;
          icon = Icons.warning_amber_rounded;
          break;
        default:
          bg = colors.onSurface.withAlpha(12);
          fg = colors.subdued;
          icon = Icons.info_outline;
      }
    } else {
      bg = colors.onSurface.withAlpha(12);
      fg = colors.subdued;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            tag,
            style: textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w400,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  bool _isCodeStatus(String tag) {
    final codeStatuses = ['dnr', 'dni', 'full', 'full code', 'limited'];
    return codeStatuses.contains(tag);
  }

  void _showTagInfo(BuildContext context, String tag) {
    final tagLower = tag.toLowerCase();
    String title;
    String description;
    IconData icon;

    if (tagLower.contains('fall')) {
      title = 'Fall Risk';
      description =
          'Patient has been identified as having an increased risk of falling. Extra precautions should be taken when ambulating or transferring.';
      icon = Icons.warning_amber_rounded;
    } else if (tagLower.contains('isolation')) {
      title = 'Isolation Precautions';
      description =
          'Patient requires isolation precautions. Follow proper PPE protocols and isolation procedures when providing care.';
      icon = Icons.security;
    } else if (_isCodeStatus(tagLower)) {
      switch (tagLower) {
        case 'dnr':
          title = 'DNR - Do Not Resuscitate';
          description =
              'Patient has a Do Not Resuscitate order. Do not perform CPR or other resuscitative measures in case of cardiac or respiratory arrest.';
          icon = Icons.heart_broken;
          break;
        case 'dni':
          title = 'DNI - Do Not Intubate';
          description =
              'Patient has a Do Not Intubate order. Do not perform endotracheal intubation or mechanical ventilation.';
          icon = Icons.remove_circle_outline;
          break;
        case 'full':
        case 'full code':
          title = 'Full Code';
          description =
              'Patient is full code. All resuscitative efforts including CPR, intubation, and advanced life support should be performed if needed.';
          icon = Icons.favorite;
          break;
        case 'limited':
          title = 'Limited Code';
          description =
              'Patient has limited code status. Some interventions are permitted while others are restricted. Check specific orders for details.';
          icon = Icons.warning_amber_rounded;
          break;
        default:
          title = 'Code Status';
          description =
              'Code status is specified but details are unclear. Please verify with patient chart or physician.';
          icon = Icons.info_outline;
      }
    } else {
      title = tag;
      description =
          'Additional patient information or risk factor. Please refer to patient chart for more details.';
      icon = Icons.info_outline;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon,
                  size: 24, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          content: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLineWithIcon({
    required IconData icon,
    required String text,
    TextStyle? textStyle,
    Color? color,
  }) {
    final fontSize = textStyle?.fontSize ?? 14;
    final iconSize =
        fontSize.clamp(12.0, 18.0); // 🔥 constrained responsive icon size

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .center, // 🔥 center alignment for better visual balance
        children: [
          SizedBox(
            width: iconSize + 2, // 🔥 consistent icon container width
            height: fontSize * 1.2, // 🔥 height matches text line height
            child: Icon(
              icon,
              size: iconSize,
              color: color ?? Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: textStyle?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
