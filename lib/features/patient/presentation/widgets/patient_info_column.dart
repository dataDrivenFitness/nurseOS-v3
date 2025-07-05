import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/patient_extensions.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/models/diagnosis_catalog.dart';
import 'package:url_launcher/url_launcher.dart';

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

    final codeStatus = patient.codeStatus?.trim();
    if (codeStatus?.isNotEmpty == true) {
      tags.add(codeStatus!);
    }

    // Add all non-risk-prefixed tags (e.g., "Isolation", "Fall Risk")
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

        // 💉 Diagnoses sorted by risk level
        ..._buildDiagnosisList(patient.primaryDiagnoses),

        // 📍 Residence or Facility
        if (patient.isAtResidence && patient.mapLaunchUrl != null)
          GestureDetector(
            onTap: () async {
              final url = Uri.parse(patient.mapLaunchUrl!);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            child: _buildLineWithIcon(
              icon: Icons.home,
              text: 'Residence',
              textStyle: textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.underline,
              ),
              color: colors.subdued,
            ),
          )
        else if (patient.facilityLocationDisplay != null)
          _buildLineWithIcon(
            icon: Icons.location_on,
            text: patient.facilityLocationDisplay!,
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
            color: colors.subdued,
          ),

        // ⚠️ Allergies
        if (allergies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 16,
                  height: (textTheme.labelSmall?.fontSize ?? 14) * 1.2,
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: (textTheme.labelSmall?.fontSize ?? 14)
                        .clamp(12.0, 18.0),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    allergies.join(', '),
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 🏷️ Tags (e.g. DNR, Isolation)
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

  List<Widget> _buildDiagnosisList(List<String> diagnoses) {
    final sorted = [...diagnoses]..sort((a, b) {
        final riskA = getRiskForDiagnosis(a);
        final riskB = getRiskForDiagnosis(b);
        return riskA.index.compareTo(riskB.index);
      });

    return sorted
        .map((diagnosis) => _buildLineWithIcon(
              icon: Icons.medical_services,
              text: diagnosis,
              textStyle: textTheme.bodySmall,
              color: colors.subdued,
            ))
        .toList();
  }

  Widget _buildTagChip(String tag) {
    final tagLower = tag.toLowerCase();
    Color bg;
    Color fg;
    IconData? icon;

    if (tagLower.contains('fall')) {
      bg = colors.warning.withAlpha(30);
      fg = colors.warning;
      icon = Icons.warning_amber_rounded;
    } else if (tagLower.contains('isolation')) {
      bg = colors.brandAccent.withAlpha(30);
      fg = colors.brandAccent;
      icon = Icons.security;
    } else if (_isCodeStatus(tagLower)) {
      switch (tagLower) {
        case 'dnr':
          bg = colors.danger.withAlpha(38);
          fg = colors.danger;
          icon = Icons.heart_broken;
          break;
        case 'dni':
          bg = colors.warning.withAlpha(38);
          fg = colors.warning;
          icon = Icons.remove_circle_outline;
          break;
        case 'full':
        case 'full code':
          bg = colors.success.withAlpha(38);
          fg = colors.success;
          icon = Icons.favorite;
          break;
        case 'limited':
          bg = colors.brandAccent.withAlpha(38);
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
    String explanation;

    if (tagLower.contains('fall')) {
      explanation = 'This patient has been marked as a fall risk.';
    } else if (tagLower.contains('isolation')) {
      explanation = 'This patient requires isolation precautions.';
    } else if (_isCodeStatus(tagLower)) {
      switch (tagLower) {
        case 'dnr':
          explanation =
              'Do Not Resuscitate: No life-saving measures should be performed.';
          break;
        case 'dni':
          explanation =
              'Do Not Intubate: No mechanical ventilation if breathing stops.';
          break;
        case 'full':
        case 'full code':
          explanation =
              'Full Code: All resuscitative measures should be taken.';
          break;
        case 'limited':
          explanation =
              'Limited Code: Only specific interventions are allowed.';
          break;
        default:
          explanation = 'Code status: $tag';
      }
    } else {
      explanation = 'Tag: $tag';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tag Info'),
        content: Text(explanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildLineWithIcon({
    required IconData icon,
    required String text,
    TextStyle? textStyle,
    Color? color,
  }) {
    final fontSize = textStyle?.fontSize ?? 14;
    final iconSize = fontSize.clamp(12.0, 18.0);

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: iconSize + 2,
            height: fontSize * 1.2,
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
