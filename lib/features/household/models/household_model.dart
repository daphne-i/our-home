import 'package:cloud_firestore/cloud_firestore.dart';

// This is our custom household model, based on the Firestore Data Structure
// in your design document.
// Path: /households/{householdId}
class HouseholdModel {
  final String id;
  final String name;
  final String ownerId;
  final List<String> members;
  final String inviteCode;
  final Timestamp createdAt;

  HouseholdModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.members,
    required this.inviteCode,
    required this.createdAt,
  });

  // Factory constructor to create a HouseholdModel from a Firestore document
  factory HouseholdModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HouseholdModel(
      id: doc.id,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      inviteCode: data['inviteCode'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Method to convert a HouseholdModel to a Map for writing to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ownerId': ownerId,
      'members': members,
      'inviteCode': inviteCode,
      'createdAt': createdAt,
    };
  }
}
