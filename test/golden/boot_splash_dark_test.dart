import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurseos_v3/shared/widgets/boot_splash.dart';

void main() {
  testWidgets('BootSplash – dark mode', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(platformBrightness: Brightness.dark),
        child: BootSplash(),
      ),
    );
    await expectLater(
      find.byType(BootSplash),
      matchesGoldenFile('boot_splash_dark.png'),
    );
  });
}
