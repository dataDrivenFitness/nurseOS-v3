import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('NurseOS v3 is live 🔥', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
