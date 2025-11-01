import 'package:cloud_firestore/cloud_firestore.dart';

// This is our custom user model, based on the Firestore Data Structure
// in your design document.
// Path: /users/{userId}
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? householdId; // Nullable, as a new user won't have one
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.householdId,
    required this.createdAt,
  });

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      householdId: data['householdId'], // This will be null if not present
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Method to convert a UserModel to a Map for writing to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'householdId': householdId,
      'createdAt': createdAt,
    };
  }
}
