import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homely/features/finance/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore;

  CategoryService(this._firestore);

  CollectionReference _getCategoryCollection(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('expenseCategories');
  }

  // Get a stream of categories
  Stream<List<CategoryModel>> getCategoriesStream(String householdId) {
    return _getCategoryCollection(householdId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    });
  }

  // Add a new category
  Future<void> addCategory({
    required String householdId,
    required String categoryName,
  }) async {
    await _getCategoryCollection(householdId).add({'name': categoryName});
  }

  // Delete a category
  Future<void> deleteCategory({
    required String householdId,
    required String categoryId,
  }) async {
    await _getCategoryCollection(householdId).doc(categoryId).delete();
  }

  // BATCH add default categories
  Future<void> addDefaultCategories(
      String householdId, List<String> defaults) async {
    final batch = _firestore.batch();
    final collection = _getCategoryCollection(householdId);

    for (final categoryName in defaults) {
      final docRef = collection.doc();
      batch.set(docRef, {'name': categoryName});
    }
    await batch.commit();
  }
}
