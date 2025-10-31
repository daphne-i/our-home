import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: FilledButton(
          onPressed: () {
            // TODO: Implement login logic
            print('Login button pressed');
          },
          child: const Text('Login (Placeholder)'),
        ),
      ),
    );
  }
}
