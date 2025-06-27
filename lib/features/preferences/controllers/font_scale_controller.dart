import 'package:flutter_riverpod/flutter_riverpod.dart';

final fontScaleControllerProvider =
    NotifierProvider<FontScaleController, double>(FontScaleController.new);

class FontScaleController extends Notifier<double> {
  @override
  double build() => 1.0; // Default text scale (100%)

  void setScale(double scale) {
    state = scale.clamp(0.8, 2.0);
  }

  void reset() => state = 1.0;
}
