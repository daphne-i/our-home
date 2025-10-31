import 'package:flutter/material.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the "Planner" screen (Tab 1)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
      ),
      body: const Center(
        child: Text(
          'Planner Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
