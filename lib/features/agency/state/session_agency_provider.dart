import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sessionAgencyProvider =
    StateNotifierProvider<SessionAgencyController, String?>(
  (ref) => SessionAgencyController(),
);

class SessionAgencyController extends StateNotifier<String?> {
  static const _key = 'activeAgencyId';

  SessionAgencyController() : super(null) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_key);
    state = cached;
  }

  Future<void> setAgency(String agencyId) async {
    state = agencyId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, agencyId);
  }

  Future<void> clear() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
