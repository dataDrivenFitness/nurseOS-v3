// 📁 lib/l10n/l10n.dart

// Re-export generated localization interface
export 'generated/app_localizations.dart';

import 'package:flutter/widgets.dart';
import 'generated/app_localizations.dart';

/// Easy access to localized strings using `context.l10n`
extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
