import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// --- NEW: Import the new screens ---
import 'package:homely/features/household/presentation/screens/household_create_screen.dart';
import 'package:homely/features/household/presentation/screens/household_join_screen.dart';

// This is Screen 4 from the design document
class HouseholdSetupScreen extends ConsumerWidget {
  const HouseholdSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // --- UPDATED: Navigate to Screen 5 ---
    void createHousehold() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateHouseholdScreen()),
      );
    }

    // --- UPDATED: Navigate to Screen 6 ---
    void joinHousehold() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const JoinHouseholdScreen()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Your Household'),
        automaticallyImplyLeading: false, // No back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40), // Add top spacing
            Text(
              'Welcome!',
              textAlign: TextAlign.center,
              style: theme.textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            Text(
              "You're one step away. A household links you with your family to share lists, tasks, and more.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),

            // "Create a New Household" button (Screen 4)
            FilledButton(
              onPressed: createHousehold, // --- UPDATED ---
              child: const Text('CREATE A NEW HOUSEHOLD'),
            ),
            const SizedBox(height: 16),

            // "Join an Existing Household" button (Screen 4)
            FilledButton.tonal(
              // Use tonal for secondary action
              onPressed: joinHousehold, // --- UPDATED ---
              child: const Text('JOIN AN EXISTING HOUSEHOLD'),
            ),
          ],
        ),
      ),
    );
  }
}
