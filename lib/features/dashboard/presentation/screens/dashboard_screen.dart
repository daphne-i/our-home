import 'package:flutter/material.dart';
import 'package:homely/core/app_theme.dart';
// --- Settings button is no longer needed here ---

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the main "Dashboard" screen (Tab 0)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Morning!'),
        // --- UPDATED: Removed the redundant actions button ---
        // actions: [ ... ],
      ),
      body: ListView(
        // Use padding from theme for consistency
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
        children: const [
          // We will build the Dashboard Cards here in Phase 2
          // Example of using the CardTheme from app_theme.dart
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingMedium),
              child: Text('Dashboard Content Goes Here'),
            ),
          ),
        ],
      ),
    );
  }
}
