// lib/features/preferences/domain/patient_display_option.dart

enum PatientDisplayOption {
  allergies,
  codeStatus,
  pronouns,
  tags,
}

extension PatientDisplayOptionLabel on PatientDisplayOption {
  String get label {
    switch (this) {
      case PatientDisplayOption.allergies:
        return "Show Allergy Information";
      case PatientDisplayOption.codeStatus:
        return "Show Code Status";
      case PatientDisplayOption.pronouns:
        return "Show Pronouns";
      case PatientDisplayOption.tags:
        return "Show Special Risk Tags";
    }
  }
}
