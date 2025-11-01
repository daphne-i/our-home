import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/features/auth/presentation/screens/login_screen.dart';
import 'package:homely/features/auth/providers/auth_providers.dart';

// --- UPDATED: Converted to ConsumerStatefulWidget ---
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
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
  void _createAccount() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authControllerProvider.notifier).signUpWithEmail(
              _emailController.text.trim(),
              _passwordController.text.trim(),
              _nameController.text.trim(),
            );
        // Pop back to let AuthGate handle navigation
        if (mounted) {
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        // Handle specific auth errors
        if (e.code == 'weak-password') {
          _showErrorSnackBar('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          _showErrorSnackBar('An account already exists for that email.');
        } else {
          _showErrorSnackBar('Error: ${e.message}');
        }
      } catch (e) {
        // Handle other errors
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
        title: const Text('Create your account'),
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
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                // Disable button when loading
                onPressed: isLoading ? null : _createAccount,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('CREATE ACCOUNT'),
              ),
              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
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
      ),
    );
  }
}
