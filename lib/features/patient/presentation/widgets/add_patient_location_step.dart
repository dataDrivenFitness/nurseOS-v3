import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/patient/models/patient_field_options.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';

class AddPatientLocationStep extends StatelessWidget {
  // Existing location parameters
  final String? location;
  final TextEditingController departmentController;
  final TextEditingController roomController;
  final TextEditingController address1Controller;
  final TextEditingController address2Controller;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController zipController;
  final ValueChanged<String?> onLocationChanged;

  // 🆕 NEW: Agency and shift parameters
  final String? selectedAgencyId;
  final String? selectedShiftId;
  final bool createNewShift;
  final List<ScheduledShiftModel> availableShifts;
  final DateTime? shiftStartTime;
  final DateTime? shiftEndTime;
  final ValueChanged<String?> onAgencyChanged;
  final ValueChanged<bool> onShiftModeChanged;
  final ValueChanged<String?> onShiftSelected;
  final Function(DateTime?, DateTime?) onShiftTimeChanged;

  const AddPatientLocationStep({
    super.key,
    // Existing parameters
    required this.location,
    required this.departmentController,
    required this.roomController,
    required this.address1Controller,
    required this.address2Controller,
    required this.cityController,
    required this.stateController,
    required this.zipController,
    required this.onLocationChanged,
    // 🆕 NEW: Agency and shift parameters
    required this.selectedAgencyId,
    required this.selectedShiftId,
    required this.createNewShift,
    required this.availableShifts,
    required this.shiftStartTime,
    required this.shiftEndTime,
    required this.onAgencyChanged,
    required this.onShiftModeChanged,
    required this.onShiftSelected,
    required this.onShiftTimeChanged,
  });

  bool get _isResidence => location?.toLowerCase() == 'residence';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 🆕 Agency & Shift Context Section
          FormCard(
            title: 'Agency & Shift Assignment',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Agency Selection
                DropdownButtonFormField<String>(
                  value: selectedAgencyId,
                  decoration: const InputDecoration(
                    labelText: 'Agency/Practice *',
                    hintText: 'Select or add agency',
                    border: OutlineInputBorder(),
                    helperText: 'Which agency/practice is this patient for?',
                  ),
                  items: _buildAgencyDropdownItems(),
                  onChanged: onAgencyChanged,
                  validator: (val) =>
                      val == null ? 'Please select an agency' : null,
                ),

                const SizedBox(height: SpacingTokens.lg),

                // Shift Selection Mode
                Text(
                  'Shift Assignment',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: SpacingTokens.sm),

                // Radio buttons for shift mode
                Column(
                  children: [
                    RadioListTile<bool>(
                      title: Text('Create new shift'),
                      subtitle: Text('Start a new shift for this patient'),
                      value: true,
                      groupValue: createNewShift,
                      onChanged: (value) => onShiftModeChanged(value ?? true),
                      dense: true,
                    ),
                    RadioListTile<bool>(
                      title: Text('Add to existing shift'),
                      subtitle: Text(availableShifts.isEmpty
                          ? 'No available shifts found'
                          : '${availableShifts.length} shift(s) available'),
                      value: false,
                      groupValue: createNewShift,
                      onChanged: availableShifts.isEmpty
                          ? null
                          : (value) => onShiftModeChanged(value ?? false),
                      dense: true,
                    ),
                  ],
                ),

                const SizedBox(height: SpacingTokens.md),

                // Show appropriate shift form based on mode
                if (createNewShift)
                  _buildQuickShiftCreationForm(context)
                else
                  _buildExistingShiftSelection(),
              ],
            ),
          ),

          const SizedBox(height: SpacingTokens.lg),

          // Existing Location Details Section
          FormCard(
            title: 'Location Details',
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: location,
                  decoration: const InputDecoration(
                    labelText: 'Location Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: locationOptions
                      .map((loc) =>
                          DropdownMenuItem(value: loc, child: Text(loc)))
                      .toList(),
                  onChanged: onLocationChanged,
                  validator: (val) =>
                      val == null ? 'Please select a location' : null,
                ),
                const SizedBox(height: SpacingTokens.md),

                // Conditional location fields (existing logic)
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
                        const SizedBox(width: SpacingTokens.md),
                        Expanded(
                          child: TextFormField(
                            controller: stateController,
                            decoration: const InputDecoration(
                              labelText: 'State',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.md),
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
          ),
        ],
      ),
    );
  }

  /// 🆕 Build agency dropdown with hardcoded options for now
  List<DropdownMenuItem<String>> _buildAgencyDropdownItems() {
    // TODO: Replace with actual agency provider/service
    final agencies = [
      {'id': 'default_agency', 'name': 'Default Agency'},
      {'id': 'metro_hospital', 'name': 'Metro General Hospital'},
      {'id': 'sunrise_care', 'name': 'Sunrise Home Care'},
      {'id': 'independent', 'name': 'Independent Practice'},
    ];

    return agencies.map((agency) {
      return DropdownMenuItem<String>(
        value: agency['id'],
        child: Text(agency['name']!),
      );
    }).toList()
      ..add(
        const DropdownMenuItem<String>(
          value: 'add_new',
          child: Row(
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 8),
              Text('Add New Agency'),
            ],
          ),
        ),
      );
  }

  /// 🆕 Quick shift creation form for new shifts
  Widget _buildQuickShiftCreationForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Shift Setup',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: SpacingTokens.md),

          // Date and time selection
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, size: 20),
                  title: Text(
                    shiftStartTime != null
                        ? _formatDate(shiftStartTime!)
                        : 'Select Date',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: const Text('Shift Date'),
                  onTap: () => _selectShiftDate(context),
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time, size: 20),
                  title: Text(
                    shiftStartTime != null
                        ? _formatTimeRange(shiftStartTime!, shiftEndTime!)
                        : '8 AM - 4 PM',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: const Text('Shift Hours'),
                  onTap: () => _selectShiftTimes(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: SpacingTokens.sm),

          // Quick time presets
          Wrap(
            spacing: 8,
            children: [
              _buildTimePresetChip(context, '7 AM - 7 PM', 7, 19),
              _buildTimePresetChip(context, '8 AM - 4 PM', 8, 16),
              _buildTimePresetChip(context, '11 PM - 7 AM', 23, 7),
            ],
          ),
        ],
      ),
    );
  }

  /// 🆕 Existing shift selection dropdown
  Widget _buildExistingShiftSelection() {
    if (availableShifts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                'No upcoming shifts found for this agency. Create a new shift instead.',
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: selectedShiftId,
      decoration: const InputDecoration(
        labelText: 'Select Existing Shift',
        border: OutlineInputBorder(),
        helperText: 'Patient will be added to this shift',
      ),
      items: availableShifts.map((shift) {
        return DropdownMenuItem<String>(
          value: shift.id,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_formatDate(shift.startTime)} • ${_formatTimeRange(shift.startTime, shift.endTime)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${shift.facilityName ?? shift.addressLine1} • ${shift.assignedPatientIds?.length ?? 0} patients',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onShiftSelected,
      validator: (val) => val == null ? 'Please select a shift' : null,
    );
  }

  /// 🆕 Time preset chip widget
  Widget _buildTimePresetChip(
      BuildContext context, String label, int startHour, int endHour) {
    final isSelected = shiftStartTime?.hour == startHour &&
        (shiftEndTime?.hour == endHour ||
            (endHour < startHour && shiftEndTime?.hour == endHour));

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          final now = DateTime.now();
          final date = shiftStartTime ?? DateTime(now.year, now.month, now.day);
          final start = DateTime(date.year, date.month, date.day, startHour);
          final end = endHour > startHour
              ? DateTime(date.year, date.month, date.day, endHour)
              : DateTime(date.year, date.month, date.day + 1,
                  endHour); // Next day for overnight shifts

          onShiftTimeChanged(start, end);
        }
      },
    );
  }

  /// 🆕 Date selection dialog
  Future<void> _selectShiftDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: shiftStartTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      final currentStart =
          shiftStartTime ?? DateTime(picked.year, picked.month, picked.day, 8);
      final currentEnd =
          shiftEndTime ?? DateTime(picked.year, picked.month, picked.day, 16);

      final newStart = DateTime(picked.year, picked.month, picked.day,
          currentStart.hour, currentStart.minute);
      final newEnd = DateTime(picked.year, picked.month, picked.day,
          currentEnd.hour, currentEnd.minute);

      onShiftTimeChanged(newStart, newEnd);
    }
  }

  /// 🆕 Time selection dialog
  Future<void> _selectShiftTimes(BuildContext context) async {
    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(shiftStartTime ?? DateTime.now()),
    );

    if (startTime != null) {
      final endTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            shiftEndTime ?? DateTime.now().add(const Duration(hours: 8))),
      );

      if (endTime != null) {
        final date = shiftStartTime ?? DateTime.now();
        final start = DateTime(
            date.year, date.month, date.day, startTime.hour, startTime.minute);
        final end = DateTime(
            date.year, date.month, date.day, endTime.hour, endTime.minute);

        onShiftTimeChanged(start, end);
      }
    }
  }

  /// Helper formatting methods
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == tomorrow) return 'Tomorrow';

    return '${date.month}/${date.day}';
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    final startTime = TimeOfDay.fromDateTime(start);
    final endTime = TimeOfDay.fromDateTime(end);
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }
}
