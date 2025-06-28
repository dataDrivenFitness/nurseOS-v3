// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get nurse => 'Enfermera';

  @override
  String get patients => 'Pacientes';

  @override
  String get assignedPatients => 'Pacientes asignados';

  @override
  String get noPatientsAssigned => 'No hay pacientes asignados.';

  @override
  String get failedToLoadPatients => 'No se pudieron cargar los pacientes.';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get loginFailed => 'Error al iniciar sesión';

  @override
  String get loginSubtitle =>
      'Inicio de sesión seguro para profesionales de la salud';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get preferences => 'Preferencias';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get displaySettings => 'Configuración de visualización de pacientes';

  @override
  String get accessibility => 'Accesibilidad';

  @override
  String get logOut => 'Cerrar sesión';
}
