import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the "Library" screen (Tab 2)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: const Center(
        child: Text(
          'Library Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
