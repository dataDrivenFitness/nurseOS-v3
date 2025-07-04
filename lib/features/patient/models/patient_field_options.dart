// 📁 lib/features/patient/models/patient_field_options.dart

import 'package:nurseos_v3/features/patient/models/patient_risk.dart';

/// 🌍 Common patient field options
const locationOptions = [
  'Residence',
  'Hospital',
  'SNF', // skilled nursing facility
  'Rehab',
  'Assisted Living',
  'Memory Care',
  'Other',
];

const languageOptions = [
  'English',
  'Spanish',
  'Mandarin',
  'Tagalog',
  'Vietnamese',
  'Cantonese',
  'Arabic',
  'Korean',
  'Other',
];

const codeStatusOptions = [
  'DNR',
  'DNI',
  'FULL',
  'LIMITED',
];

const biologicalSexOptions = [
  'Male',
  'Female',
  'Intersex',
  'Unspecified',
];
