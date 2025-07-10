// 📁 lib/features/patient/presentation/screens/add_patient_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/patient/data/patient_repository_provider.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
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

class AddPatientScreen extends ConsumerStatefulWidget {
  const AddPatientScreen({super.key});

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Controllers
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

  int _currentStep = 0;
  bool _mrnExists = false;
  bool _isValidatingMrn = false;

  bool get _isResidence => _location?.toLowerCase() == 'residence';

  @override
  void initState() {
    super.initState();
    _mrnController.addListener(_checkMrn);
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

  Future<void> _checkMrn() async {
    final mrn = _mrnController.text.trim();
    if (mrn.isEmpty) return;

    setState(() => _isValidatingMrn = true);
    final existing = await FirebaseFirestore.instance
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _mrnExists) return;

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final id = FirebaseFirestore.instance.collection('patients').doc().id;
    String? photoUrl;

    if (_profileImage != null) {
      final fileRef =
          FirebaseStorage.instance.ref('patients/profile_photos/$id.jpg');
      final upload = await fileRef.putFile(_profileImage!);
      photoUrl = await upload.ref.getDownloadURL();
    }

    final patient = Patient(
      id: id,
      agencyId: user.activeAgencyId, // ✅ REQUIRED
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
      assignedNurses: [],
      mrn: _mrnController.text.trim().isEmpty
          ? null
          : _mrnController.text.trim(),
      birthDate: _birthDate,
      biologicalSex: _biologicalSex ?? 'unspecified',
      language: _language,
      photoUrl: photoUrl,
      department: !_isResidence ? _departmentController.text.trim() : null,
      roomNumber: !_isResidence ? _roomController.text.trim() : null,
      addressLine1: _isResidence ? _address1Controller.text.trim() : null,
      addressLine2: _isResidence ? _address2Controller.text.trim() : null,
      city: _isResidence ? _cityController.text.trim() : null,
      state: _isResidence ? _stateController.text.trim() : null,
      zip: _isResidence ? _zipController.text.trim() : null,
      pronouns: _pronounsController.text.trim().isEmpty
          ? null
          : _pronounsController.text.trim(),
      codeStatus: _codeStatusController.text.trim().isEmpty
          ? null
          : _codeStatusController.text.trim(),
    );

    final repo = ref.read(patientRepositoryProvider)!;
    final result = await repo.save(patient);

    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: ${error.message}'),
            backgroundColor: Colors.red),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Patient saved'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      },
    );
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
                    label: _currentStep < 3 ? 'Next' : 'Save Patient',
                    onPressed: _currentStep < 3
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                            setState(() => _currentStep++);
                          }
                        : _submit,
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
