import 'dart:collection';

import 'abstract_xp_repository.dart';

/// Mock XP repository for dev/testing
class MockXpRepository implements AbstractXpRepository {
  final _mockXp = HashMap<String, int>();

  @override
  Future<int> getXp(String userId) async {
    return _mockXp[userId] ?? 0;
  }

  @override
  Future<void> incrementXp(String userId, {int amount = 1}) async {
    final current = _mockXp[userId] ?? 0;
    _mockXp[userId] = current + amount;
  }
}
