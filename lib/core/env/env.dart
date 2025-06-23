import 'package:flutter_dotenv/flutter_dotenv.dart';

bool get useMockServices {
  // If DotEnv is not initialised (e.g. .env missing), default to mock mode.
  if (!dotenv.isInitialized) return true;

  final raw = dotenv.env['USE_MOCK_SERVICES']?.toLowerCase();
  // Default to mock when var is absent or "true".
  return raw == null || raw == 'true';
}

void logEnv() {
  final raw = dotenv.isInitialized ? dotenv.env['USE_MOCK_SERVICES'] : 'null';
  // ignore: avoid_print
  print('[env] USE_MOCK_SERVICES=$useMockServices (raw=$raw)');
}
