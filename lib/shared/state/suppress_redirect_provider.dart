import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls whether GoRouter should suppress default redirects temporarily
final suppressRedirectProvider = StateProvider<bool>((ref) => false);
