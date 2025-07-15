// 📁 lib/features/patient/presentation/screens/add_patient_screen.dart
// Updated for shift-centric architecture

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/patient/data/patient_repository_provider.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/add_patient_basic_info_step.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/add_patient_location_step.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/add_patient_clinical_step.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/add_patient_risk_step.dart';
import 'package:nurseos_v3/features/patient/presentation/screens/select_allergies_screen.dart';
import 'package:nurseos_v3/features/patient/presentation/screens/select_diagnosis_screen.dart';
import 'package:nurseos_v3/features/patient/presentation/screens/select_dietary_restrictions_screen.dart';

import 'package:nurseos_v3/shared/utils/image_picker_utils.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/shared/widgets/buttons/secondary_button.dart';
import 'package:nurseos_v3/shared/widgets/app_snackbar.dart';

class AddPatientScreen extends ConsumerStatefulWidget {
  const AddPatientScreen({super.key});

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Existing Controllers
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

  // Existing Form State
  String? _location;
  String? _language;
  String? _biologicalSex;
  DateTime? _birthDate;
  File? _profileImage;
  List<String> _diagnoses = [];
  List<String> _allergies = [];
  List<String> _dietaryRestrictions = [];
  bool _isFallRisk = false;
  bool _isIsolation = false;

  // 🆕 SHIFT-CENTRIC: New State Variables
  String? _selectedAgencyId;
  String? _selectedShiftId;
  bool _createNewShift = true;
  DateTime? _shiftStartTime;
  DateTime? _shiftEndTime;
  List<ScheduledShiftModel> _availableShifts = [];

  // Existing UX State
  int _currentStep = 0;
  bool _mrnExists = false;
  bool _isValidatingMrn = false;
  bool _isSubmitting = false;

  bool get _isResidence => _location?.toLowerCase() == 'residence';

  @override
  void initState() {
    super.initState();
    _mrnController.addListener(_checkMrn);
    _initializeAgencyContext();
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

  /// 🆕 Initialize agency context and set defaults
  void _initializeAgencyContext() {
    final user = ref.read(authControllerProvider).value;
    if (user?.activeAgencyId != null) {
      _selectedAgencyId = user!.activeAgencyId;
      _loadAvailableShifts();
    }
  }

  /// 🆕 Load available shifts for selected agency
  Future<void> _loadAvailableShifts() async {
    if (_selectedAgencyId == null) return;

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekFromNow = now.add(const Duration(days: 7));

      // Query for nurse's shifts in the selected agency within the next week
      final query = await firestore
          .collection('agencies')
          .doc(_selectedAgencyId!)
          .collection('scheduledShifts')
          .where('assignedTo', isEqualTo: user.uid)
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('startTime',
              isLessThanOrEqualTo: Timestamp.fromDate(weekFromNow))
          .orderBy('startTime')
          .get();

      final shifts = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ScheduledShiftModel.fromJson(data);
      }).toList();

      setState(() {
        _availableShifts = shifts;
        // If we have shifts, default to adding to existing
        if (shifts.isNotEmpty) {
          _createNewShift = false;
          _selectedShiftId = shifts.first.id;
        }
      });
    } catch (e) {
      debugPrint('Error loading available shifts: $e');
    }
  }

  // Existing methods remain the same...
  Future<void> _checkMrn() async {
    final mrn = _mrnController.text.trim();
    if (mrn.isEmpty) return;

    setState(() => _isValidatingMrn = true);

    // 🔧 Update to use agency-scoped collection
    final existing = await FirebaseFirestore.instance
        .collection('agencies')
        .doc(_selectedAgencyId ?? 'default_agency')
        .collection('patients')
        .where('mrn', isEqualTo: mrn)
        .limit(1)
        .get();

    setState(() {
      _mrnExists = existing.docs.isNotEmpty;
      _isValidatingMrn = false;
    });
  }

  Future<void> _pickImage() async {
    final file = await pickAndCropImage(context: context, isCircular: true);
    if (file != null) setState(() => _profileImage = file);
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _selectDiagnoses() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => SelectDiagnosisScreen(initialSelection: _diagnoses)),
    );
    if (selected != null)
      setState(() => _diagnoses = List<String>.from(selected));
  }

  Future<void> _selectAllergies() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => SelectAllergyScreen(initialSelection: _allergies)),
    );
    if (selected != null)
      setState(() => _allergies = List<String>.from(selected));
  }

  Future<void> _selectDietaryRestrictions() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => SelectDietaryRestrictionScreen(
              initialSelection: _dietaryRestrictions)),
    );
    if (selected != null)
      setState(() => _dietaryRestrictions = List<String>.from(selected));
  }

  /// 🆕 SHIFT-CENTRIC: Updated submit method
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _mrnExists) return;

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final repo = ref.read(patientRepositoryProvider);
    if (repo == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Step 1: Upload profile image if exists
      String? photoUrl;
      if (_profileImage != null) {
        final id = FirebaseFirestore.instance.collection('patients').doc().id;
        final fileRef =
            FirebaseStorage.instance.ref('patients/profile_photos/$id.jpg');
        final upload = await fileRef.putFile(_profileImage!);
        photoUrl = await upload.ref.getDownloadURL();
      }

      // Step 2: Create patient (WITHOUT assignedNurses field)
      final patient = Patient(
        id: '', // Will be set by repository
        agencyId: _selectedAgencyId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        location: _location!,
        createdAt: DateTime.now(),
        createdBy: user.uid,
        admittedAt: DateTime.now(),
        ownerUid: user.uid,
        isFallRisk: _isFallRisk,
        isIsolation: _isIsolation,
        primaryDiagnoses: _diagnoses,
        allergies: _allergies,
        dietRestrictions: _dietaryRestrictions,
        // ✅ NO assignedNurses field - this is the key change!
        mrn: _mrnController.text.trim().isEmpty
            ? null
            : _mrnController.text.trim(),
        birthDate: _birthDate,
        biologicalSex: _biologicalSex ?? 'unspecified',
        language: _language,
        photoUrl: photoUrl,
        department: !_isResidence
            ? _departmentController.text.trim().nullIfEmpty
            : null,
        roomNumber:
            !_isResidence ? _roomController.text.trim().nullIfEmpty : null,
        addressLine1:
            _isResidence ? _address1Controller.text.trim().nullIfEmpty : null,
        addressLine2:
            _isResidence ? _address2Controller.text.trim().nullIfEmpty : null,
        city: _isResidence ? _cityController.text.trim().nullIfEmpty : null,
        state: _isResidence ? _stateController.text.trim().nullIfEmpty : null,
        zip: _isResidence ? _zipController.text.trim().nullIfEmpty : null,
        pronouns: _pronounsController.text.trim().nullIfEmpty,
        codeStatus: _codeStatusController.text.trim().nullIfEmpty,
      );

      // Step 3: Save patient to get generated ID
      String? savedPatientId;
      final result = await repo.save(patient);

      await result.fold(
        (failure) async {
          throw Exception('Failed to save patient: ${failure.message}');
        },
        (success) async {
          // Patient saved successfully, get the ID for shift assignment
          savedPatientId =
              patient.id.isNotEmpty ? patient.id : _generatePatientId();
        },
      );

      // Step 4: 🚨 SHIFT-CENTRIC: Create or update shift with patient assignment
      if (savedPatientId != null) {
        if (_createNewShift) {
          await _createNewShiftWithPatient(savedPatientId!, user.uid);
        } else {
          await _addPatientToExistingShift(savedPatientId!, _selectedShiftId!);
        }
      }

      if (mounted) {
        AppSnackbar.success(
          context,
          _createNewShift
              ? 'Patient added and new shift created'
              : 'Patient added to existing shift',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to add patient: $e');
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  /// 🆕 Create new shift with patient assigned
  Future<void> _createNewShiftWithPatient(
      String patientId, String nurseUid) async {
    final firestore = FirebaseFirestore.instance;

    // Create default shift times if not set
    final now = DateTime.now();
    final startTime =
        _shiftStartTime ?? DateTime(now.year, now.month, now.day, 8); // 8 AM
    final endTime = _shiftEndTime ??
        startTime.add(const Duration(hours: 8)); // 8-hour shift

    final shiftData = {
      'agencyId': _selectedAgencyId,
      'assignedTo': nurseUid,
      'status': 'scheduled',
      'locationType': _isResidence ? 'residence' : 'facility',
      'facilityName':
          !_isResidence ? _departmentController.text.trim().nullIfEmpty : null,
      'addressLine1':
          _isResidence ? _address1Controller.text.trim().nullIfEmpty : null,
      'addressLine2':
          _isResidence ? _address2Controller.text.trim().nullIfEmpty : null,
      'city': _isResidence ? _cityController.text.trim().nullIfEmpty : null,
      'state': _isResidence ? _stateController.text.trim().nullIfEmpty : null,
      'zip': _isResidence ? _zipController.text.trim().nullIfEmpty : null,
      'assignedPatientIds': [
        patientId
      ], // 🎯 This is where patient gets attached to shift
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isConfirmed': true,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await firestore
        .collection('agencies')
        .doc(_selectedAgencyId ?? 'default_agency')
        .collection('scheduledShifts')
        .add(shiftData);
  }

  /// 🆕 Add patient to existing shift
  Future<void> _addPatientToExistingShift(
      String patientId, String shiftId) async {
    final firestore = FirebaseFirestore.instance;

    final shiftRef = firestore
        .collection('agencies')
        .doc(_selectedAgencyId ?? 'default_agency')
        .collection('scheduledShifts')
        .doc(shiftId);

    await shiftRef.update({
      'assignedPatientIds':
          FieldValue.arrayUnion([patientId]), // 🎯 Add patient to shift
    });
  }

  /// Helper to generate patient ID if repository doesn't return it
  String _generatePatientId() {
    return FirebaseFirestore.instance.collection('patients').doc().id;
  }

  @override
  Widget build(BuildContext context) {
    return NurseScaffold(
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AddPatientBasicInfoStep(
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
                  // 🆕 Updated location step will include agency/shift selection
                  AddPatientLocationStep(
                    location: _location,
                    departmentController: _departmentController,
                    roomController: _roomController,
                    address1Controller: _address1Controller,
                    address2Controller: _address2Controller,
                    cityController: _cityController,
                    stateController: _stateController,
                    zipController: _zipController,
                    onLocationChanged: (value) =>
                        setState(() => _location = value),
                    // 🆕 NEW: Agency and shift parameters
                    selectedAgencyId: _selectedAgencyId,
                    selectedShiftId: _selectedShiftId,
                    createNewShift: _createNewShift,
                    availableShifts: _availableShifts,
                    shiftStartTime: _shiftStartTime,
                    shiftEndTime: _shiftEndTime,
                    onAgencyChanged: (agencyId) {
                      setState(() {
                        _selectedAgencyId = agencyId;
                        _availableShifts.clear();
                        _selectedShiftId = null;
                      });
                      _loadAvailableShifts();
                    },
                    onShiftModeChanged: (createNew) {
                      setState(() => _createNewShift = createNew);
                    },
                    onShiftSelected: (shiftId) {
                      setState(() => _selectedShiftId = shiftId);
                    },
                    onShiftTimeChanged: (start, end) {
                      setState(() {
                        _shiftStartTime = start;
                        _shiftEndTime = end;
                      });
                    },
                  ),
                  AddPatientClinicalStep(
                    mrnController: _mrnController,
                    primaryDiagnoses: _diagnoses,
                    selectedAllergies: _allergies,
                    selectedDietRestrictions: _dietaryRestrictions,
                    mrnExists: _mrnExists,
                    isValidatingMrn: _isValidatingMrn,
                    onSelectDiagnoses: _selectDiagnoses,
                    onSelectAllergies: _selectAllergies,
                    onSelectDietRestrictions: _selectDietaryRestrictions,
                  ),
                  AddPatientRiskStep(
                    codeStatusController: _codeStatusController,
                    isIsolation: _isIsolation,
                    isFallRisk: _isFallRisk,
                    onIsolationChanged: (val) =>
                        setState(() => _isIsolation = val),
                    onFallRiskChanged: (val) =>
                        setState(() => _isFallRisk = val),
                    onCodeStatusChanged: (val) =>
                        setState(() => _codeStatusController.text = val ?? ''),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: _currentStep == 0 ? 'Cancel' : 'Back',
                    onPressed: _currentStep == 0
                        ? () => Navigator.pop(context)
                        : () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                            setState(() => _currentStep--);
                          },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    label: _currentStep < 3
                        ? 'Next'
                        : (_isSubmitting ? 'Saving...' : 'Save Patient'),
                    onPressed: _isSubmitting
                        ? null
                        : (_currentStep < 3
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                setState(() => _currentStep++);
                              }
                            : _submit),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extension helper for null-if-empty strings
extension StringHelper on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
