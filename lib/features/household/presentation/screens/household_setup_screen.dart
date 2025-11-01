import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This is Screen 4 from the design document
class HouseholdSetupScreen extends ConsumerWidget {
  const HouseholdSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    void createHousehold() {
      // TODO: Implement Create Household (Screen 5)
      print('Navigate to Create Household flow');
      // Temporary: Show a snackbar for now
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create Household feature coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    void joinHousehold() {
      // TODO: Implement Join Household (Screen 6)
      print('Navigate to Join Household flow');
      // Temporary: Show a snackbar for now
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Join Household feature coming soon!'),
          duration: Duration(seconds: 2),
        ),
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
              onPressed: createHousehold,
              child: const Text('CREATE A NEW HOUSEHOLD'),
            ),
            const SizedBox(height: 16),

            // "Join an Existing Household" button (Screen 4)
            FilledButton.tonal(
              // Use tonal for secondary action
              onPressed: joinHousehold,
              child: const Text('JOIN AN EXISTING HOUSEHOLD'),
            ),
          ],
        ),
      ),
    );
  }
}
