import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/patient/models/patient_field_options.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';

class AddPatientLocationStep extends StatelessWidget {
  final String? location;
  final TextEditingController departmentController;
  final TextEditingController roomController;
  final TextEditingController address1Controller;
  final TextEditingController address2Controller;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController zipController;
  final ValueChanged<String?> onLocationChanged;

  const AddPatientLocationStep({
    super.key,
    required this.location,
    required this.departmentController,
    required this.roomController,
    required this.address1Controller,
    required this.address2Controller,
    required this.cityController,
    required this.stateController,
    required this.zipController,
    required this.onLocationChanged,
  });

  bool get _isResidence => location?.toLowerCase() == 'residence';

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Where is the patient?',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: location,
            decoration: const InputDecoration(
              labelText: 'Location Type *',
              border: OutlineInputBorder(),
            ),
            items: locationOptions
                .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                .toList(),
            onChanged: onLocationChanged,
            validator: (val) => val == null ? 'Please select a location' : null,
          ),
          const SizedBox(height: SpacingTokens.md),
          if (location != null) ...[
            if (!_isResidence) ...[
              TextFormField(
                controller: departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  hintText: 'e.g., ICU, Emergency, Surgery',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              TextFormField(
                controller: roomController,
                decoration: const InputDecoration(
                  labelText: 'Room Number',
                  hintText: 'e.g., 201A, ICU-3',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else ...[
              TextFormField(
                controller: address1Controller,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  hintText: '123 Main Street',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              TextFormField(
                controller: address2Controller,
                decoration: const InputDecoration(
                  labelText: 'Apt/Unit (optional)',
                  hintText: 'Apt 2B',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Expanded(
                    child: TextFormField(
                      controller: stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Expanded(
                    child: TextFormField(
                      controller: zipController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'ZIP',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
