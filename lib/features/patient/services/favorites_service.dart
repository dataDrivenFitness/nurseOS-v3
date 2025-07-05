// 📁 lib/features/patient/services/favorites_service.dart

import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user favorites across different medical item types
class FavoritesService {
  static const String _diagnosisFavoritesKey = 'user_favorite_diagnoses';
  static const String _allergyFavoritesKey = 'user_favorite_allergies';
  static const String _dietaryFavoritesKey =
      'user_favorite_dietary_restrictions';
  static const String _recentDiagnosesKey = 'user_recent_diagnoses';
  static const String _recentAllergiesKey = 'user_recent_allergies';
  static const String _recentDietaryKey = 'user_recent_dietary_restrictions';
  static const int _maxRecentItems = 10;

  // ═══════════════════════════════════════════════════════════════
  // 🏥 DIAGNOSIS FAVORITES
  // ═══════════════════════════════════════════════════════════════

  /// Load user's favorite diagnoses from local storage
  static Future<List<String>> loadFavoriteDiagnoses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_diagnosisFavoritesKey) ?? [];
    } catch (e) {
      print('⚠️ Error loading favorite diagnoses: $e');
      return [];
    }
  }

  /// Save user's favorite diagnoses to local storage
  static Future<void> saveFavoriteDiagnoses(List<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_diagnosisFavoritesKey, favorites);
      print('✅ Saved ${favorites.length} favorite diagnoses');
    } catch (e) {
      print('⚠️ Error saving favorite diagnoses: $e');
    }
  }

  /// Toggle a diagnosis in favorites list
  static Future<List<String>> toggleFavoriteDiagnosis(
      String diagnosisId) async {
    final favorites = await loadFavoriteDiagnoses();

    if (favorites.contains(diagnosisId)) {
      favorites.remove(diagnosisId);
      print('🔄 Removed diagnosis from favorites: $diagnosisId');
    } else {
      favorites.add(diagnosisId);
      print('🔄 Added diagnosis to favorites: $diagnosisId');
    }

    await saveFavoriteDiagnoses(favorites);
    return favorites;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🕒 DIAGNOSIS RECENT TRACKING
  // ═══════════════════════════════════════════════════════════════

  /// Add multiple items to recently used when user makes selections
  static Future<List<String>> addRecentDiagnoses(
      List<String> selectedIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var recent = prefs.getStringList(_recentDiagnosesKey) ?? [];

      // Add each selected item to front (newest first)
      for (final id in selectedIds.reversed) {
        recent.remove(id); // Remove if already exists
        recent.insert(0, id); // Add to front
      }

      // Keep only last N items
      if (recent.length > _maxRecentItems) {
        recent = recent.take(_maxRecentItems).toList();
      }

      await prefs.setStringList(_recentDiagnosesKey, recent);
      print(
          '🕒 Added ${selectedIds.length} items to recent diagnoses. Total: ${recent.length}');
      return recent;
    } catch (e) {
      print('⚠️ Error saving recent diagnoses: $e');
      return [];
    }
  }

  /// Load recently used diagnoses
  static Future<List<String>> loadRecentDiagnoses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentDiagnosesKey) ?? [];
    } catch (e) {
      print('⚠️ Error loading recent diagnoses: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🚨 ALLERGY FAVORITES
  // ═══════════════════════════════════════════════════════════════

  /// Load user's favorite allergies from local storage
  static Future<List<String>> loadFavoriteAllergies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_allergyFavoritesKey) ?? [];
    } catch (e) {
      print('⚠️ Error loading favorite allergies: $e');
      return [];
    }
  }

  /// Save user's favorite allergies to local storage
  static Future<void> saveFavoriteAllergies(List<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_allergyFavoritesKey, favorites);
      print('✅ Saved ${favorites.length} favorite allergies');
    } catch (e) {
      print('⚠️ Error saving favorite allergies: $e');
    }
  }

  /// Toggle an allergy in favorites list
  static Future<List<String>> toggleFavoriteAllergy(String allergyId) async {
    final favorites = await loadFavoriteAllergies();

    if (favorites.contains(allergyId)) {
      favorites.remove(allergyId);
      print('🔄 Removed allergy from favorites: $allergyId');
    } else {
      favorites.add(allergyId);
      print('🔄 Added allergy to favorites: $allergyId');
    }

    await saveFavoriteAllergies(favorites);
    return favorites;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🕒 ALLERGY RECENT TRACKING
  // ═══════════════════════════════════════════════════════════════

  /// Add multiple allergies to recently used
  static Future<List<String>> addRecentAllergies(
      List<String> selectedIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var recent = prefs.getStringList(_recentAllergiesKey) ?? [];

      for (final id in selectedIds.reversed) {
        recent.remove(id);
        recent.insert(0, id);
      }

      if (recent.length > _maxRecentItems) {
        recent = recent.take(_maxRecentItems).toList();
      }

      await prefs.setStringList(_recentAllergiesKey, recent);
      print(
          '🕒 Added ${selectedIds.length} items to recent allergies. Total: ${recent.length}');
      return recent;
    } catch (e) {
      print('⚠️ Error saving recent allergies: $e');
      return [];
    }
  }

  /// Load recently used allergies
  static Future<List<String>> loadRecentAllergies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentAllergiesKey) ?? [];
    } catch (e) {
      print('⚠️ Error loading recent allergies: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🍽️ DIETARY RESTRICTION FAVORITES
  // ═══════════════════════════════════════════════════════════════

  /// Load user's favorite dietary restrictions from local storage
  static Future<List<String>> loadFavoriteDietaryRestrictions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_dietaryFavoritesKey) ?? [];
    } catch (e) {
      print('⚠️ Error loading favorite dietary restrictions: $e');
      return [];
    }
  }

  /// Save user's favorite dietary restrictions to local storage
  static Future<void> saveFavoriteDietaryRestrictions(
      List<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_dietaryFavoritesKey, favorites);
      print('✅ Saved ${favorites.length} favorite dietary restrictions');
    } catch (e) {
      print('⚠️ Error saving favorite dietary restrictions: $e');
    }
  }

  /// Toggle a dietary restriction in favorites list
  static Future<List<String>> toggleFavoriteDietaryRestriction(
      String restrictionId) async {
    final favorites = await loadFavoriteDietaryRestrictions();

    if (favorites.contains(restrictionId)) {
      favorites.remove(restrictionId);
      print('🔄 Removed dietary restriction from favorites: $restrictionId');
    } else {
      favorites.add(restrictionId);
      print('🔄 Added dietary restriction to favorites: $restrictionId');
    }

    await saveFavoriteDietaryRestrictions(favorites);
    return favorites;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🕒 DIETARY RECENT TRACKING
  // ═══════════════════════════════════════════════════════════════

  /// Add multiple dietary restrictions to recently used
  static Future<List<String>> addRecentDietaryRestrictions(
      List<String> selectedIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var recent = prefs.getStringList(_recentDietaryKey) ?? [];

      for (final id in selectedIds.reversed) {
        recent.remove(id);
        recent.insert(0, id);
      }

      if (recent.length > _maxRecentItems) {
        recent = recent.take(_maxRecentItems).toList();
      }

      await prefs.setStringList(_recentDietaryKey, recent);
      print(
          '🕒 Added ${selectedIds.length} items to recent dietary restrictions. Total: ${recent.length}');
      return recent;
    } catch (e) {
      print('⚠️ Error saving recent dietary restrictions: $e');
      return [];
    }
  }

  /// Load recently used dietary restrictions
  static Future<List<String>> loadRecentDietaryRestrictions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentDietaryKey) ?? [];
    } catch (e) {
      print('⚠️ Error loading recent dietary restrictions: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔧 UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Clear all favorites (useful for testing or user logout)
  static Future<void> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_diagnosisFavoritesKey);
      await prefs.remove(_allergyFavoritesKey);
      await prefs.remove(_dietaryFavoritesKey);
      print('✅ Cleared all favorites');
    } catch (e) {
      print('⚠️ Error clearing favorites: $e');
    }
  }

  /// Clear all recent items (useful for testing)
  static Future<void> clearAllRecent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentDiagnosesKey);
      await prefs.remove(_recentAllergiesKey);
      await prefs.remove(_recentDietaryKey);
      print('✅ Cleared all recent items');
    } catch (e) {
      print('⚠️ Error clearing recent items: $e');
    }
  }

  /// Get total count of all favorites
  static Future<int> getTotalFavoritesCount() async {
    final diagnoses = await loadFavoriteDiagnoses();
    final allergies = await loadFavoriteAllergies();
    final dietary = await loadFavoriteDietaryRestrictions();

    return diagnoses.length + allergies.length + dietary.length;
  }

  /// Check if any favorites exist
  static Future<bool> hasFavorites() async {
    final count = await getTotalFavoritesCount();
    return count > 0;
  }
}
