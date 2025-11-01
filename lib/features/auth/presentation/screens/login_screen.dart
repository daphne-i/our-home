import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/features/auth/presentation/screens/register_screen.dart';
import 'package:homely/features/auth/providers/auth_providers.dart';

// --- UPDATED: Converted to ConsumerStatefulWidget ---
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  // --- UPDATED: Wired up to AuthService ---
  void _logIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authControllerProvider.notifier).signInWithEmail(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
        // Pop back to let AuthGate handle navigation
        if (mounted) {
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          _showErrorSnackBar('Invalid email or password.');
        } else {
          _showErrorSnackBar('Error: ${e.message}');
        }
      } catch (e) {
        _showErrorSnackBar('An unexpected error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the loading state from our provider
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in to your account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // --- UPDATED: Added Form with validation ---
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          // TODO: Add forgot password flow
                        },
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                // Disable button when loading
                onPressed: isLoading ? null : _logIn,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('LOG IN'),
              ),
              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
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
      ),
    );
  }
}
