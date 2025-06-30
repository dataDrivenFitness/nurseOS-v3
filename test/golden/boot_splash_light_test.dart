import 'package:flutter_test/flutter_test.dart';
import 'package:nurseos_v3/shared/widgets/boot_splash.dart';

void main() {
  testWidgets('BootSplash – light mode', (tester) async {
    await tester.pumpWidget(const BootSplash());
    await expectLater(
      find.byType(BootSplash),
      matchesGoldenFile('boot_splash_light.png'),
    );
  });
}
