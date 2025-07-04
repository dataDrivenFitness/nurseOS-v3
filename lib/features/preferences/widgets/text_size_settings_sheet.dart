import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/spacing.dart';
import '../controllers/font_scale_controller.dart';

class TextSizeSettingsSheet extends StatefulWidget {
  const TextSizeSettingsSheet({super.key});

  static const _scaleOptions = [
    (label: 'Small', description: 'For users with good vision', scale: 0.85),
    (label: 'Standard', description: 'Default size', scale: 1.0),
    (label: 'Large', description: 'Easier to read', scale: 1.25),
    (label: 'Extra Large', description: 'Much easier to read', scale: 1.5),
    (label: 'Maximum', description: 'Largest available size', scale: 1.75),
  ];

  // ✅ Static method to show modal with completely isolated environment
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _IsolatedTextSizeDialog(
        originalTheme: Theme.of(context),
        originalMediaQuery: MediaQuery.of(context),
      ),
    );
  }

  @override
  State<TextSizeSettingsSheet> createState() => _TextSizeSettingsSheetState();
}

class _TextSizeSettingsSheetState extends State<TextSizeSettingsSheet> {
  double _currentScale = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentScale();
  }

  Future<void> _loadCurrentScale() async {
    try {
      // Get current scale from provider context
      final container = ProviderScope.containerOf(context);
      final fontScaleAsync = container.read(fontScaleControllerProvider);
      final scale = fontScaleAsync.value ?? 1.0;

      setState(() {
        _currentScale = scale;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentScale = 1.0;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateScale(double newScale) async {
    setState(() {
      _currentScale = newScale;
    });

    try {
      // Update through provider
      final container = ProviderScope.containerOf(context);
      final controller = container.read(fontScaleControllerProvider.notifier);
      await controller.updateScale(newScale);
    } catch (e) {
      // Handle error silently for now
      debugPrint('Error updating scale: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Fixed size header text
            Text(
              'Adjust Text Size',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              "Choose a text size that's comfortable for you to read.",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),

            // ✅ Preview section - ONLY this should scale
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  // ✅ ONLY this text scales
                  Text(
                    'Patient vitals: BP 120/80, HR 72 bpm, Temp 98.6°F',
                    style: TextStyle(
                      fontSize: 16 * _currentScale, // Direct scaling
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: SpacingTokens.lg),

            // ✅ Option tiles - completely fixed size
            ...TextSizeSettingsSheet._scaleOptions.map((option) {
              return _FixedSizeOptionTile(
                label: option.label,
                description: option.description,
                selected: _currentScale == option.scale,
                onTap: () => _updateScale(option.scale),
              );
            }),

            const SizedBox(height: SpacingTokens.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Completely isolated dialog with zero text scaling
class _IsolatedTextSizeDialog extends StatelessWidget {
  final ThemeData originalTheme;
  final MediaQueryData originalMediaQuery;

  const _IsolatedTextSizeDialog({
    required this.originalTheme,
    required this.originalMediaQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: originalMediaQuery.size.height * 0.8,
          maxWidth: originalMediaQuery.size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: originalTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: originalTheme.copyWith(
            // ✅ Remove ALL text scaling from theme
            textTheme: originalTheme.textTheme.apply(fontSizeFactor: 1.0),
          ),
          builder: (context, child) {
            // ✅ Force no text scaling at MediaQuery level
            return MediaQuery(
              data: originalMediaQuery.copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
          home: Scaffold(
            backgroundColor: Colors.transparent,
            body: const ProviderScope(
              child: TextSizeSettingsSheet(),
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ Fixed size option tile that completely resists any scaling
class _FixedSizeOptionTile extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _FixedSizeOptionTile({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? Colors.blue : Colors.grey.shade300,
          width: selected ? 2.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
        color: selected ? Colors.blue.shade50 : null,
      ),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16, // ✅ Absolutely fixed font size
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            fontSize: 14, // ✅ Absolutely fixed font size
          ),
        ),
        trailing: selected
            ? const Icon(Icons.radio_button_checked,
                color: Colors.blue, size: 24)
            : const Icon(Icons.radio_button_unchecked,
                color: Colors.grey, size: 24),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
