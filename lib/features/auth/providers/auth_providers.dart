import 'package:flutter_riverpod/flutter_riverpod.dart';
// --- Import Firebase Auth ---
import 'package:firebase_auth/firebase_auth.dart';

// --- REMOVED: Temporary AppUser class ---

// This provider will be used to listen to the user's auth state.
// It streams the current user.
final authStateProvider = StreamProvider<User?>((ref) {
  // <-- Type is User?

  // --- Return the real Firebase auth state stream ---
  return FirebaseAuth.instance.authStateChanges();

  // --- REMOVED: Placeholder stream ---
});
