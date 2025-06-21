import 'package:flutter_dotenv/flutter_dotenv.dart';

final bool useMockServices =
    dotenv.env['USE_MOCK_SERVICES']?.toLowerCase() == 'true';
