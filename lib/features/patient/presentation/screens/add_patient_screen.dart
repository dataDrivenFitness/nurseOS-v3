import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/patient/data/patient_repository_provider.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/presentation/screens/select_diagnosis_screen.dart';
import 'package:nurseos_v3/features/patient/state/patient_providers.dart';
import 'package:nurseos_v3/features/patient/models/patient_field_options.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/shared/widgets/buttons/secondary_button.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';
import 'package:nurseos_v3/shared/utils/image_picker_utils.dart';
import 'package:nurseos_v3/shared/widgets/profile_avatar.dart';

class AddPatientScreen extends ConsumerStatefulWidget {
  const AddPatientScreen({super.key});

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Text Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mrnController = TextEditingController();
  final _departmentController = TextEditingController();
  final _roomController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _pronounsController = TextEditingController();
  final _codeStatusController = TextEditingController();

  // Form State
  String? _location;
  String? _language;
  String? _biologicalSex;
  List<String> _primaryDiagnoses = [];
  DateTime? _birthDate;
  bool _isIsolation = false;
  bool _isFallRisk = false;
  File? _profileImage;

  // UX State Management
  int _currentStep = 0;
  bool _mrnExists = false;
  bool _isValidatingMrn = false;
  String? _mrnError;

  // Form completion tracking
  Map<int, bool> _stepCompletion = {0: false, 1: false, 2: false, 3: false};

  bool get _isResidence => _location?.toLowerCase() == 'residence';
  bool get _canProceedToNext => _stepCompletion[_currentStep] ?? false;

  @override
  void initState() {
    super.initState();
    _setupValidation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mrnController.dispose();
    _departmentController.dispose();
    _roomController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _pronounsController.dispose();
    _codeStatusController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────
  // Setup & Validation
  // ──────────────────────────────────────────────────────────────

  void _setupValidation() {
    _mrnController.addListener(_validateMrn);
    _firstNameController.addListener(_updateStepCompletion);
    _lastNameController.addListener(_updateStepCompletion);
  }

  void _updateStepCompletion() {
    setState(() {
      _stepCompletion[0] = _firstNameController.text.trim().isNotEmpty &&
          _lastNameController.text.trim().isNotEmpty &&
          _birthDate != null;

      _stepCompletion[1] = _location != null;

      _stepCompletion[2] = true; // Clinical info is optional

      _stepCompletion[3] = true; // Risk flags are optional
    });
  }

  Future<void> _validateMrn() async {
    final mrn = _mrnController.text.trim();
    if (mrn.isEmpty) {
      setState(() {
        _mrnExists = false;
        _mrnError = null;
        _isValidatingMrn = false;
      });
      return;
    }

    setState(() => _isValidatingMrn = true);

    try {
      final existing = await FirebaseFirestore.instance
          .collection('patients')
          .where('mrn', isEqualTo: mrn)
          .limit(1)
          .get();

      setState(() {
        _mrnExists = existing.docs.isNotEmpty;
        _mrnError = _mrnExists ? 'MRN already exists' : null;
        _isValidatingMrn = false;
      });
    } catch (e) {
      setState(() {
        _mrnError = 'Error validating MRN';
        _isValidatingMrn = false;
      });
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Navigation
  // ──────────────────────────────────────────────────────────────

  void _nextStep() {
    if (_currentStep < 3 && _canProceedToNext) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  // ──────────────────────────────────────────────────────────────
  // Input Handlers
  // ──────────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picked = await pickAndCropImage(
      context: context,
      isCircular: true,
    );
    if (picked != null) {
      setState(() => _profileImage = picked);
    }
  }

  void _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select patient birthdate',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
      _updateStepCompletion();
    }
  }

  Future<void> _selectDiagnoses() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SelectDiagnosisScreen(initialSelection: _primaryDiagnoses),
      ),
    );
    if (selected != null) {
      setState(() => _primaryDiagnoses = List<String>.from(selected));
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Save Patient
  // ──────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _mrnExists) return;

    final messenger = ScaffoldMessenger.of(context);
    final db = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    final repo = ref.read(patientRepositoryProvider)!;
    final user = ref.read(authControllerProvider).value;

    _showLoadingDialog();

    final id = db.collection('patients').doc().id;

    String? photoUrl;
    if (_profileImage != null) {
      try {
        final fileRef = storage.ref().child('patients/profile_photos/$id.jpg');
        final uploadTask = await fileRef.putFile(_profileImage!);
        photoUrl = await uploadTask.ref.getDownloadURL();
      } catch (e) {
        debugPrint('⚠️ Image upload failed: $e');
      }
    }

    final patient = Patient(
      id: id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      mrn: _mrnController.text.trim().isEmpty
          ? null
          : _mrnController.text.trim(),
      location: _location ?? 'other',
      birthDate: _birthDate,
      isFallRisk: _isFallRisk,
      isIsolation: _isIsolation,
      primaryDiagnoses: _primaryDiagnoses,
      language: _language,
      biologicalSex: _biologicalSex ?? 'unspecified',
      createdAt: DateTime.now(),
      admittedAt: DateTime.now(),
      createdBy: user?.uid,
      ownerUid: user?.uid,
      photoUrl: photoUrl,
      addressLine1: _address1Controller.text.trim(),
      addressLine2: _address2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zip: _zipController.text.trim(),
      roomNumber: _roomController.text.trim(),
      pronouns: _pronounsController.text.trim(),
      codeStatus: _codeStatusController.text.trim(),
      department: _departmentController.text.trim(),
    );

    final result = await repo.save(patient);

    Navigator.of(context).pop(); // Close loading dialog

    result.fold(
      (failure) {
        messenger.showSnackBar(SnackBar(
          content: Text('Failed to add patient: ${failure.message}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _submit,
          ),
        ));
      },
      (_) {
        ref.invalidate(patientProvider);
        messenger.showSnackBar(const SnackBar(
          content: Text('✅ Patient added successfully!'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      },
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Saving patient...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // UI Components
  // ──────────────────────────────────────────────────────────────

  Widget _buildProgressIndicator() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurface.withAlpha(38),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepTitle() {
    final titles = [
      'Patient Information',
      'Location Details',
      'Clinical Information',
      'Risk Assessment'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${_currentStep + 1} of 4',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            titles[_currentStep],
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    final patientName = _firstNameController.text.trim().isEmpty &&
            _lastNameController.text.trim().isEmpty
        ? 'Patient'
        : '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    return Column(
      children: [
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(60),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ProfileAvatar(
              file: _profileImage,
              photoUrl: null,
              fallbackName: patientName,
              radius: 50,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add patient photo',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoStep() {
    return FormCard(
      title: 'Essential Information',
      child: Column(
        children: [
          _buildPhotoSection(),
          const SizedBox(height: 24),
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name *',
              hintText: 'Enter patient\'s first name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (val) =>
                val == null || val.isEmpty ? 'First name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name *',
              hintText: 'Enter patient\'s last name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (val) =>
                val == null || val.isEmpty ? 'Last name is required' : null,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickBirthDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _birthDate != null
                          ? 'Birthdate: ${_birthDate!.toLocal().toString().split(' ')[0]}'
                          : 'Select Birthdate *',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pronounsController,
            decoration: const InputDecoration(
              labelText: 'Pronouns (optional)',
              hintText: 'e.g., they/them, she/her, he/him',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _biologicalSex,
            decoration: const InputDecoration(
              labelText: 'Biological Sex (optional)',
              border: OutlineInputBorder(),
            ),
            items: biologicalSexOptions
                .map((sex) => DropdownMenuItem(value: sex, child: Text(sex)))
                .toList(),
            onChanged: (val) => setState(() => _biologicalSex = val),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _language,
            decoration: const InputDecoration(
              labelText: 'Preferred Language (optional)',
              border: OutlineInputBorder(),
            ),
            items: languageOptions
                .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                .toList(),
            onChanged: (val) => setState(() => _language = val),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return FormCard(
      title: 'Where is the patient?',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _location,
            decoration: const InputDecoration(
              labelText: 'Location Type *',
              border: OutlineInputBorder(),
            ),
            items: locationOptions
                .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
                .toList(),
            onChanged: (val) {
              setState(() => _location = val);
              _updateStepCompletion();
            },
            validator: (val) => val == null ? 'Please select a location' : null,
          ),
          const SizedBox(height: 16),
          if (_location != null) ...[
            if (!_isResidence) ...[
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  hintText: 'e.g., ICU, Emergency, Surgery',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room Number',
                  hintText: 'e.g., 201A, ICU-3',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else ...[
              TextFormField(
                controller: _address1Controller,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  hintText: '123 Main Street',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _address2Controller,
                decoration: const InputDecoration(
                  labelText: 'Apt/Unit (optional)',
                  hintText: 'Apt 2B',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _zipController,
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

  Widget _buildClinicalStep() {
    return FormCard(
      title: 'Clinical Information',
      child: Column(
        children: [
          TextFormField(
            controller: _mrnController,
            decoration: InputDecoration(
              labelText: 'Medical Record Number (MRN)',
              hintText: 'Enter MRN if available',
              border: const OutlineInputBorder(),
              errorText: _mrnError,
              suffixIcon: _isValidatingMrn
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _mrnExists
                      ? const Icon(Icons.error, color: Colors.red)
                      : _mrnController.text.isNotEmpty && !_mrnExists
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectDiagnoses,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Primary Diagnoses',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[600]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _primaryDiagnoses.isEmpty
                      ? Text('Tap to add diagnoses',
                          style: TextStyle(color: Colors.grey[600]))
                      : Wrap(
                          spacing: 8,
                          children: _primaryDiagnoses
                              .map((dx) => Chip(
                                    label: Text(dx),
                                    backgroundColor: Colors.blue[50],
                                  ))
                              .toList(),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _codeStatusController.text.isEmpty
                ? null
                : _codeStatusController.text,
            decoration: const InputDecoration(
              labelText: 'Code Status',
              border: OutlineInputBorder(),
            ),
            items: codeStatusOptions
                .map((status) =>
                    DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (val) =>
                setState(() => _codeStatusController.text = val ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskStep() {
    return FormCard(
      title: 'Risk Assessment',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please review and set any applicable risk flags for this patient.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            color: _isIsolation ? Colors.red[50] : Colors.grey[50],
            child: SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: const Text('Isolation Precautions'),
              subtitle: const Text('Patient requires isolation protocols'),
              value: _isIsolation,
              onChanged: (val) => setState(() => _isIsolation = val),
              secondary: Icon(
                Icons.medical_services,
                color: _isIsolation ? Colors.red : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: _isFallRisk ? Colors.orange[50] : Colors.grey[50],
            child: SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: const Text('Fall Risk'),
              subtitle: const Text('Patient has elevated fall risk'),
              value: _isFallRisk,
              onChanged: (val) => setState(() => _isFallRisk = val),
              secondary: Icon(
                Icons.accessibility,
                color: _isFallRisk ? Colors.orange : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Left button – Cancel or Back
          Flexible(
            flex: 1,
            child: SecondaryButton(
              label: _currentStep == 0 ? 'Cancel' : 'Back',
              onPressed: _currentStep == 0 ? _cancel : _previousStep,
              icon: Icon(
                _currentStep == 0 ? Icons.close : Icons.arrow_back,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right button – Continue or Save
          Flexible(
            flex: 2,
            child: _currentStep < 3
                ? PrimaryButton(
                    label: 'Continue',
                    onPressed: _canProceedToNext ? _nextStep : null,
                  )
                : PrimaryButton(
                    label: 'Save Patient',
                    onPressed: _mrnExists ? null : _submit,
                  ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Main Build
  // ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return NurseScaffold(
      child: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Step title
          const SizedBox(height: 16),
          _buildStepTitle(),
          const SizedBox(height: 24),

          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildBasicInfoStep(),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildLocationStep(),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildClinicalStep(),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildRiskStep(),
                  ),
                ],
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }
}
