import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homely/features/auth/domain/user_model.dart';
import 'package:homely/features/household/presentation/screens/household_setup_screen.dart';
import 'package:homely/features/auth/providers/auth_providers.dart';
import 'package:homely/features/auth/presentation/screens/welcome_screen.dart';
import 'package:homely/main_app_shell.dart';
import 'package:homely/core/providers/firestore_providers.dart';

// This is now the "Household Gate"
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the Firebase Auth state
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // 1A. Auth state is loading (checking if user is logged in)
      loading: () => const _LoadingScreen(),

      // 1B. Error checking auth
      error: (err, stack) => _ErrorScreen(err.toString()),

      // 1C. Auth state is known (User? object)
      data: (User? firebaseUser) {
        // --- STATE 1: LOGGED OUT ---
        if (firebaseUser == null) {
          return const WelcomeScreen();
        }

        // --- STATE 2: LOGGED IN ---
        // User is logged in, now we must check their *Firestore document*
        // to see if they have a household.
        final userModelAsync = ref.watch(userProvider(firebaseUser.uid));

        return userModelAsync.when(
          // 2A. Loading the user's Firestore document
          loading: () => const _LoadingScreen(),

          // 2B. Error loading Firestore document - handle permission errors
          error: (err, stack) {
            // If it's a permission error, treat as missing document
            final errorString = err.toString().toLowerCase();
            if (errorString.contains('permission') ||
                errorString.contains('denied')) {
              return _CreateMissingUserDocument(firebaseUser: firebaseUser);
            }
            return _ErrorScreen(err.toString());
          },

          // 2C. We have the Firestore document (or null)
          data: (UserModel? userModel) {
            if (userModel == null) {
              // User is logged in but Firestore document is missing.
              // This can happen for existing Firebase Auth users created before
              // we implemented user document creation.
              // Create the missing document automatically.
              return _CreateMissingUserDocument(firebaseUser: firebaseUser);
            }

            // --- STATE 2 (continued): LOGGED IN, NO HOUSEHOLD ---
            if (userModel.householdId == null) {
              return const HouseholdSetupScreen();
            }

            // --- STATE 3: LOGGED IN AND HAS A HOUSEHOLD ---
            return const MainAppShell();
          },
        );
      },
    );
  }
}

// Simple loading widget
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Simple error display widget
class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen(this.error);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

// Widget to create missing user document
class _CreateMissingUserDocument extends ConsumerStatefulWidget {
  final User firebaseUser;

  const _CreateMissingUserDocument({required this.firebaseUser});

  @override
  ConsumerState<_CreateMissingUserDocument> createState() =>
      _CreateMissingUserDocumentState();
}

class _CreateMissingUserDocumentState
    extends ConsumerState<_CreateMissingUserDocument> {
  @override
  void initState() {
    super.initState();
    _createUserDocument();
  }

  Future<void> _createUserDocument() async {
    try {
      final firestore = ref.read(firestoreProvider);
      final user = widget.firebaseUser;

      final newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        householdId: null,
        createdAt: Timestamp.now(),
      );

      await firestore
          .collection('users')
          .doc(user.uid)
          .set(newUser.toFirestore());

      // Refresh the auth gate to re-check the user
      if (mounted) {
        ref.invalidate(userProvider(user.uid));
      }
    } catch (e) {
      // If creation fails, sign out the user
      FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Setting up your account...'),
          ],
        ),
      ),
    );
  }
}
