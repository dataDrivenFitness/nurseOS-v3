import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemedScreenWrapper extends StatelessWidget {
  final Widget child;

  const ThemedScreenWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final overlayStyle = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: child,
    );
  }
}
