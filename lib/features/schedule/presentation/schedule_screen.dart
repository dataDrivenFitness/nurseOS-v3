// lib/features/schedule/presentation/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/models/enhanced_available_view.dart';
import 'my_schedule_view.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Schedule'),
              Tab(text: 'Available'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MyScheduleView(),
            EnhancedAvailableView(), // 👈 Updated to use enhanced view
          ],
        ),
      ),
    );
  }
}
