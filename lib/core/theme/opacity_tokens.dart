/// Defines standard alpha values (0–255) for consistent opacity use across UI.
///
/// These tokens align with WCAG contrast guidance and NurseOS UI heuristics.
class OpacityTokens {
  static const int full = 255; // 100%
  static const int high = 204; // 80%
  static const int medium = 153; // 60%
  static const int low = 102; // 40%
  static const int faint = 76; // 30%
  static const int ultraFaint = 10; // 20%

  // Semantic aliases
  static const int navIconUnselected = medium;
  static const int disabledState = low;
  static const int hintText = faint;
}
