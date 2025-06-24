abstract class AbstractXpRepository {
  /// Gets XP value for a given user
  Future<int> getXp(String userId);

  /// Increments XP for a user (only used in nurse-triggered actions)
  Future<void> incrementXp(String userId, {int amount = 1});
}
