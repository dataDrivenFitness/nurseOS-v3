// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get nurse => 'Nurse';

  @override
  String get patients => 'Patients';

  @override
  String get assignedPatients => 'Assigned Patients';

  @override
  String get noPatientsAssigned => 'No patients assigned.';

  @override
  String get failedToLoadPatients => 'Failed to load patients.';

  @override
  String get login => 'Log In';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get loginSubtitle => 'Secure login for healthcare professionals';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get preferences => 'Preferences';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get displaySettings => 'Patient Display Settings';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get logOut => 'Log Out';
}
