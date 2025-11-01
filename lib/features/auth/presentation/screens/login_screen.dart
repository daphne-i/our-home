import 'package:flutter/material.dart';
import 'package:homely/features/auth/presentation/screens/register_screen.dart';

// --- Converted to StatefulWidget to hold controllers ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _logIn() {
    // TODO: Add Firebase Auth logic here
    final email = _emailController.text;
    final password = _passwordController.text;
    print(
        'Logging in with $email and password: ${password.isNotEmpty ? "[HIDDEN]" : "[EMPTY]"}');
    // On success, AuthGate will handle navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // --- Title from design doc ---
        title: const Text('Log in to your account'),
      ),
      // --- Body with UI from design doc ---
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Add forgot password flow
                },
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _logIn,
              child: const Text('LOG IN'),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  // Pop back to Welcome, then push to Register
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Sign up"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
