import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homely/features/auth/domain/user_model.dart';
import 'package:homely/features/household/models/household_model.dart';

// This class will handle all our household creation and joining logic
class HouseholdService {
  final FirebaseFirestore _firestore;

  HouseholdService(this._firestore);

  // Helper function to generate a 6-digit invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      6,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
  }

  // Create a new household (Screen 5 logic)
  Future<void> createHousehold({
    required String householdName,
    required UserModel user,
  }) async {
    try {
      // 1. Create the new household object
      final householdRef = _firestore.collection('households').doc();
      final newHousehold = HouseholdModel(
        id: householdRef.id,
        name: householdName,
        ownerId: user.uid,
        members: [user.uid], // Add the creator as the first member
        inviteCode: _generateInviteCode(),
        createdAt: Timestamp.now(),
      );

      // 2. Write the household to Firestore in a batch
      final batch = _firestore.batch();
      batch.set(householdRef, newHousehold.toFirestore());

      // 3. Update the user's document with the new householdId
      final userRef = _firestore.collection('users').doc(user.uid);
      batch.update(userRef, {'householdId': newHousehold.id});

      // 4. Commit the batch
      await batch.commit();

      // AuthGate will see the householdId change and navigate automatically
    } catch (e) {
      // Re-throw to be caught by the UI
      rethrow;
    }
  }

  // Join an existing household (Screen 6 logic)
  Future<void> joinHousehold({
    required String inviteCode,
    required UserModel user,
  }) async {
    try {
      // 1. Find the household with the matching invite code
      final query = await _firestore
          .collection('households')
          .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Invalid invite code. Please check and try again.');
      }

      // 2. Get the household ID
      final householdDoc = query.docs.first;
      final householdId = householdDoc.id;

      // 3. Update user and household docs in a batch
      final batch = _firestore.batch();

      // 4. Update the user's document with the householdId
      final userRef = _firestore.collection('users').doc(user.uid);
      batch.update(userRef, {'householdId': householdId});

      // 5. Add the user's UID to the household's 'members' array
      batch.update(householdDoc.reference, {
        'members': FieldValue.arrayUnion([user.uid])
      });

      // 6. Commit the batch
      await batch.commit();

      // AuthGate will see the householdId change and navigate automatically
    } catch (e) {
      // Re-throw to be caught by the UI
      rethrow;
    }
  }
}
