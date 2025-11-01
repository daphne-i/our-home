import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/providers/firestore_providers.dart';
import 'package:homely/features/auth/domain/user_model.dart';

// This class will handle all our authentication and user document logic
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService(this._auth, this._firestore);

  // Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Create the user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('User creation failed.');
      }

      // 2. Create the user document in Firestore as per the design doc
      final newUser = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        householdId: null, // No household yet
        createdAt: Timestamp.now(),
      );

      // Set the document in /users/{userId}
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(newUser.toFirestore());
    } on FirebaseAuthException {
      // Re-throw the exception to be caught by the UI
      rethrow;
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Check if user document exists in Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        // If user document doesn't exist, create it
        if (!userDoc.exists) {
          final newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? 'User', // Use displayName or default
            email: user.email ?? email,
            householdId: null, // No household yet
            createdAt: Timestamp.now(),
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(newUser.toFirestore());
        }
      }
    } on FirebaseAuthException {
      // Re-throw to be caught by the UI
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

// Provider for the AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    FirebaseAuth.instance,
    ref.watch(firestoreProvider), // Get Firestore instance from our provider
  );
});
