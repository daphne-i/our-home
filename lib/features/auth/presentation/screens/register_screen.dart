import 'package:flutter/material.dart';
import 'package:homely/features/auth/presentation/screens/login_screen.dart';

// This is Screen 2 from the design document
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createAccount() {
    // TODO: Add Firebase Auth logic here
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    print(
        'Creating account for $name with $email and password: ${password.isNotEmpty ? "[HIDDEN]" : "[EMPTY]"}');
    // On success, AuthGate will automatically navigate to Screen 4 (Household Setup)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create your account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // "Name" field (Screen 2)
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your full name',
              ),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              autofocus: false,
              enabled: true,
            ),
            const SizedBox(height: 16),

            // "Email" field (Screen 2)
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // "Password" field (Screen 2)
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32),

            // "Create Account" button (Screen 2)
            FilledButton(
              onPressed: _createAccount,
              child: const Text('CREATE ACCOUNT'),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  // Pop back to Welcome, then push to Login
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Already have an account? Log in'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
