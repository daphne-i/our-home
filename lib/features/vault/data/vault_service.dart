import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homely/features/vault/models/vault_item_model.dart';

class VaultService {
  final FirebaseFirestore _firestore;

  VaultService(this._firestore);

  CollectionReference _getVaultCollection(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('vaultItems');
  }

  // Stream the vault list
  Stream<List<VaultItemModel>> getVaultItemsStream(String householdId) {
    return _getVaultCollection(householdId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VaultItemModel.fromFirestore(doc))
          .toList();
    });
  }

  // Add a new item
  Future<void> addVaultItem({
    required String householdId,
    required VaultItemModel item,
  }) async {
    // Note: In a real app, you'd handle file upload here and get the fileUrl
    await _getVaultCollection(householdId).add(item.toFirestore());
  }

  // Delete an item
  Future<void> deleteVaultItem({
    required String householdId,
    required String itemId,
  }) async {
    // Note: You'd also delete the file from Firebase Storage here
    await _getVaultCollection(householdId).doc(itemId).delete();
  }
}
