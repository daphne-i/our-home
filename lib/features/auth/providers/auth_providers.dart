import 'package:flutter_riverpod/flutter_riverpod.dart';
// TODO: Import Firebase Auth
// import 'package:firebase_auth/firebase_auth.dart';

// Temporary user class until Firebase is integrated
class AppUser {
  final String id;
  final String email;

  AppUser({required this.id, required this.email});
}

// This provider will be used to listen to the user's auth state.
// It streams the current user.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  // TODO: Uncomment this when Firebase is set up
  // return FirebaseAuth.instance.authStateChanges();

  // Placeholder stream until Firebase is ready

  // --- TEMPORARY CHANGE ---
  // OLD (Logged Out):
  // return Stream.value(null);

  // NEW (Logged In):
  return Stream.value(AppUser(id: '123', email: 'test@user.com'));
  // --- END CHANGE ---
});
