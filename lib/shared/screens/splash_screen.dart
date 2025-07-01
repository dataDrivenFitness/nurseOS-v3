import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/shared/widgets/app_loader.dart';
import 'package:nurseos_v3/core/theme/theme_controller.dart';
import 'package:nurseos_v3/core/theme/app_theme.dart';
import 'package:nurseos_v3/core/providers/shared_prefs_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeStreamProvider);
    final prefs = ref.read(sharedPreferencesProvider);

    return themeModeAsync.when(
      loading: () {
        // Fallback to SharedPreferences while theme stream loads
        final savedDarkMode = prefs.getBool('dark_mode');
        final themeMode = savedDarkMode == null
            ? ThemeMode.system
            : (savedDarkMode ? ThemeMode.dark : ThemeMode.light);

        return _buildSplashWithAppTheme(themeMode);
      },
      error: (error, stack) {
        // Fallback to SharedPreferences on error
        final savedDarkMode = prefs.getBool('dark_mode');
        final themeMode = savedDarkMode == null
            ? ThemeMode.system
            : (savedDarkMode ? ThemeMode.dark : ThemeMode.light);

        return _buildSplashWithAppTheme(themeMode);
      },
      data: (themeMode) {
        return _buildSplashWithAppTheme(themeMode);
      },
    );
  }

  /// Builds splash with your app's theme settings
  Widget _buildSplashWithAppTheme(ThemeMode themeMode) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const Scaffold(
        body: Center(child: AppLoader()),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
