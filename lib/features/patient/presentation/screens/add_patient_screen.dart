import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/patient/data/patient_repository_provider.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/presentation/screens/select_allergies_screen.dart';
import 'package:nurseos_v3/features/patient/presentation/screens/select_diagnosis_screen.dart';
import 'package:nurseos_v3/features/patient/presentation/screens/select_dietary_restrictions_screen.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/add_patient_clinical_step.dart';
import 'package:nurseos_v3/features/patient/state/patient_providers.dart';
import 'package:nurseos_v3/features/patient/models/patient_field_options.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/shared/widgets/buttons/secondary_button.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';
import 'package:nurseos_v3/shared/utils/image_picker_utils.dart';
import 'package:nurseos_v3/shared/widgets/profile_avatar.dart';

// Import the step widgets
import 'package:nurseos_v3/features/patient/presentation/widgets/add_patient_basic_info_step.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/add_patient_location_step.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/add_patient_risk_step.dart';

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
  List<String> _selectedAllergies = [];
  List<String> _selectedDietRestrictions = [];
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
  final Map<int, bool> _stepCompletion = {
    0: false,
    1: false,
    2: false,
    3: false
  };

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

  Future<void> _selectAllergies() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectAllergyScreen(
            initialSelection: _selectedAllergies), // ← Fixed class name
      ),
    );
    if (selected != null) {
      setState(() => _selectedAllergies = List<String>.from(selected));
    }
  }

  Future<void> _selectDietRestrictions() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectDietaryRestrictionScreen(
            // ← Fixed class name
            initialSelection: _selectedDietRestrictions),
      ),
    );
    if (selected != null) {
      setState(() => _selectedDietRestrictions = List<String>.from(selected));
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
      allergies: _selectedAllergies.isEmpty ? null : _selectedAllergies,
      dietRestrictions:
          _selectedDietRestrictions.isEmpty ? null : _selectedDietRestrictions,
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
                  // Step 1: Basic Info
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AddPatientBasicInfoStep(
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      pronounsController: _pronounsController,
                      birthDate: _birthDate,
                      biologicalSex: _biologicalSex,
                      language: _language,
                      profileImage: _profileImage,
                      onPickBirthDate: _pickBirthDate,
                      onPickImage: _pickImage,
                      onBiologicalSexChanged: (value) =>
                          setState(() => _biologicalSex = value),
                      onLanguageChanged: (value) =>
                          setState(() => _language = value),
                    ),
                  ),
                  // Step 2: Location
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AddPatientLocationStep(
                      location: _location,
                      departmentController: _departmentController,
                      roomController: _roomController,
                      address1Controller: _address1Controller,
                      address2Controller: _address2Controller,
                      cityController: _cityController,
                      stateController: _stateController,
                      zipController: _zipController,
                      onLocationChanged: (value) {
                        setState(() => _location = value);
                        _updateStepCompletion();
                      },
                    ),
                  ),
                  // Step 3: Clinical Info
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AddPatientClinicalStep(
                      mrnController: _mrnController,
                      primaryDiagnoses: _primaryDiagnoses,
                      selectedAllergies: _selectedAllergies,
                      selectedDietRestrictions: _selectedDietRestrictions,
                      mrnExists: _mrnExists,
                      isValidatingMrn: _isValidatingMrn,
                      mrnError: _mrnError,
                      onSelectDiagnoses: _selectDiagnoses,
                      onSelectAllergies: _selectAllergies,
                      onSelectDietRestrictions: _selectDietRestrictions,
                    ),
                  ),
                  // Step 4: Risk Assessment
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AddPatientRiskStep(
                      codeStatusController: _codeStatusController,
                      isIsolation: _isIsolation,
                      isFallRisk: _isFallRisk,
                      onIsolationChanged: (value) =>
                          setState(() => _isIsolation = value),
                      onFallRiskChanged: (value) =>
                          setState(() => _isFallRisk = value),
                      onCodeStatusChanged: (value) => setState(
                          () => _codeStatusController.text = value ?? ''),
                    ),
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
