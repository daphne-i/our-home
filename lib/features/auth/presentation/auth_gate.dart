import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// --- Import Firebase User ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homely/features/auth/providers/auth_providers.dart';
// --- Import WelcomeScreen ---
import 'package:homely/features/auth/presentation/screens/welcome_screen.dart';
import 'package:homely/main_app_shell.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state provider
    final authState = ref.watch(authStateProvider);

    // Use pattern matching on the AsyncValue
    return authState.when(
      // --- Listen for User? from Firebase ---
      data: (User? user) {
        // If user is not null (logged in), show the main app
        if (user != null) {
          // TODO: Add household check here in Phase 1.5
          return const MainAppShell();
        }
        // If user is null (logged out), show the new WelcomeScreen
        else {
          return const WelcomeScreen();
        }
      },
      loading: () {
        // Show a loading spinner while checking auth state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (err, stack) {
        // Show an error screen if auth state fails
        return Scaffold(
          body: Center(
            child: Text('Error: $err'),
          ),
        );
      },
    );
  }
}
