import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homely/features/kitchen/models/shopping_list_item_model.dart';

class ShoppingListService {
  final FirebaseFirestore _firestore;

  ShoppingListService(this._firestore);

  CollectionReference _getShoppingListCollection(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('shoppingListItems');
  }

  // Stream the shopping list
  Stream<List<ShoppingListItemModel>> getShoppingListStream(
      String householdId) {
    return _getShoppingListCollection(householdId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ShoppingListItemModel.fromFirestore(doc))
          .toList();
    });
  }

  // Add a new item
  Future<void> addItem({
    required String householdId,
    required ShoppingListItemModel item,
  }) async {
    await _getShoppingListCollection(householdId).add(item.toFirestore());
  }

  // Update an item (e.g., check/uncheck)
  Future<void> updateItem({
    required String householdId,
    required ShoppingListItemModel item,
  }) async {
    if (item.id == null) throw Exception('Cannot update item with no ID');
    await _getShoppingListCollection(householdId)
        .doc(item.id)
        .update(item.toFirestore());
  }

  // Delete an item
  Future<void> deleteItem({
    required String householdId,
    required String itemId,
  }) async {
    await _getShoppingListCollection(householdId).doc(itemId).delete();
  }

  // Clear all checked items
  Future<void> clearCheckedItems({required String householdId}) async {
    final batch = _firestore.batch();
    final query = await _getShoppingListCollection(householdId)
        .where('isChecked', isEqualTo: true)
        .get();

    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
