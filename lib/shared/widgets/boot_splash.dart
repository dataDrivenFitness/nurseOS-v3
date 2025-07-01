// lib/shared/widgets/boot_splash.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/shared/widgets/app_loader.dart';
import '../../core/theme/app_theme.dart';

class BootSplash extends StatelessWidget {
  const BootSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: Colors.transparent, // prevents hard white default
      builder: (context, _) => MediaQuery(
        data: const MediaQueryData(),
        child: Theme(
          data: WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark
              ? AppTheme.dark()
              : AppTheme.light(),
          child: const Scaffold(
            body: Center(child: AppLoader()),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
