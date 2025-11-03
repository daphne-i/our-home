import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homely/features/kitchen/models/pantry_item_model.dart';

class PantryService {
  final FirebaseFirestore _firestore;

  PantryService(this._firestore);

  CollectionReference _getPantryCollection(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('pantryItems');
  }

  // Stream the pantry list
  Stream<List<PantryItemModel>> getPantryStream(String householdId) {
    return _getPantryCollection(householdId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PantryItemModel.fromFirestore(doc))
          .toList();
    });
  }

  // Add a new item
  Future<void> addItem({
    required String householdId,
    required PantryItemModel item,
  }) async {
    await _getPantryCollection(householdId).add(item.toFirestore());
  }

  // Update an item
  Future<void> updateItem({
    required String householdId,
    required PantryItemModel item,
  }) async {
    if (item.id == null) throw Exception('Cannot update item with no ID');
    await _getPantryCollection(householdId)
        .doc(item.id)
        .update(item.toFirestore());
  }

  // Delete an item
  Future<void> deleteItem({
    required String householdId,
    required String itemId,
  }) async {
    await _getPantryCollection(householdId).doc(itemId).delete();
  }
}
