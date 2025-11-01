import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/features/auth/providers/auth_providers.dart';

// --- UPDATED: Converted to ConsumerWidget ---
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This is the "Settings" screen (Tab 3)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // --- NEW: Added a Logout Button ---
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              // Call the signOut method from our auth controller
              ref.read(authControllerProvider.notifier).signOut();
              // AuthGate will automatically handle navigation
            },
          ),
          // We will add Theme settings here later
        ],
      ),
    );
  }
}
