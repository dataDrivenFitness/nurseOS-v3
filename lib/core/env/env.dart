import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Returns `true` if the app should run in mock mode.
///
/// Defaults to `true` (safe) if the .env file is not loaded or the key is missing.
///
/// Set `USE_MOCK_SERVICES=false` in your `.env` file to use Firebase or live services.
bool get useMockServices {
  final raw = dotenv.env['USE_MOCK_SERVICES']?.toLowerCase();
  return raw == null || raw == 'true';
}

/// Logs the current environment mode for debugging.
///
/// Should be called early in app bootstrap.
void logEnv() {
  final isReady = dotenv.isInitialized;
  final rawValue = isReady ? dotenv.env['USE_MOCK_SERVICES'] : 'null';

  // Log for visibility in terminal
  // ignore: avoid_print
  print('[env] USE_MOCK_SERVICES=$useMockServices (raw=$rawValue)');
  // ignore: avoid_print
  print('[env] dotenv initialized: $isReady');
}
