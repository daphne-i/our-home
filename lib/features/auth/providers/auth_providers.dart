import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homely/core/providers/firestore_providers.dart';
import 'package:homely/features/auth/application/auth_service.dart';
import 'package:homely/features/auth/domain/user_model.dart';

// This provider just streams the Firebase Auth User object (logged in / out)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// --- NEW ---
// This provider streams the user's *data document* from Firestore.
// This is how we'll know if they have a householdId.
final userProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  final firestore = ref.watch(firestoreProvider);

  // Listen to the document at /users/{uid}
  final docStream = firestore.collection('users').doc(uid).snapshots();

  // Map the document snapshot to our UserModel
  return docStream.map((doc) {
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null; // User document doesn't exist (this is bad!)
  });
});

// --- NEW ---
// This is a simple provider to get the current user's householdId
// It depends on the other two providers.
final householdIdProvider = Provider<String?>((ref) {
  // Get the Firebase Auth user
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) {
    return null; // Not logged in
  }

  // Get the Firestore user document
  final userModel = ref.watch(userProvider(authUser.uid)).value;

  return userModel?.householdId; // Returns the ID, or null if none
});

// This is a state notifier provider for our AuthService.
// The UI will call methods on this to log in, log out, or sign up.
final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref.watch(authServiceProvider));
});

// Simple StateNotifier to manage loading state for auth actions
class AuthController extends StateNotifier<bool> {
  final AuthService _authService;
  AuthController(this._authService) : super(false); // false = not loading

  Future<void> signInWithEmail(String email, String password) async {
    state = true; // true = loading
    try {
      await _authService.signInWithEmail(email: email, password: password);
    } finally {
      state = false; // false = done loading
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    state = true;
    try {
      await _authService.signUpWithEmail(
          email: email, password: password, name: name);
    } finally {
      state = false;
    }
  }

  Future<void> signOut() async {
    state = true;
    try {
      await _authService.signOut();
    } finally {
      state = false;
    }
  }
}
