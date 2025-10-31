import 'package:flutter/material.dart';
import 'package:homely/core/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the main "Dashboard" screen (Tab 0)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Morning!'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        children: const [
          Text(
            'Dashboard Screen',
            style: TextStyle(fontSize: 24),
          ),
          // We will build the Dashboard Cards here in Phase 2
        ],
      ),
    );
  }
}
