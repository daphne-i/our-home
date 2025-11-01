import 'package:flutter/material.dart';
import 'package:homely/features/auth/presentation/screens/login_screen.dart';
import 'package:homely/features/auth/presentation/screens/register_screen.dart';

// This is Screen 1 from the design document
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TODO: Add your App Logo here (e.g., Image.asset('assets/logo.png'))
              Icon(
                Icons.home_rounded, // Placeholder icon
                size: 80,
                color: theme.colorScheme.primary, // Use theme color
              ),
              const SizedBox(height: 16),
              Text(
                'homely',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary, // Use theme color
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(), // Pushes content to top and buttons to bottom

              // "Register" button (Screen 1)
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('REGISTER'),
              ),
              const SizedBox(height: 16),

              // "Log In" button (Screen 1)
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('Log In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
