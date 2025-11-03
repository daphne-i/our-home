import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homely/features/kitchen/models/meal_plan_model.dart';

class MealPlanService {
  final FirebaseFirestore _firestore;

  MealPlanService(this._firestore);

  CollectionReference _getMealPlanCollection(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('mealPlan');
  }

  // Stream all meal plan items
  Stream<List<MealPlanModel>> getMealPlanStream(String householdId) {
    return _getMealPlanCollection(householdId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MealPlanModel.fromFirestore(doc))
          .toList();
    });
  }

  // Add a new meal to the plan
  Future<void> addMealToPlan({
    required String householdId,
    required MealPlanModel meal,
  }) async {
    await _getMealPlanCollection(householdId).add(meal.toFirestore());
  }

  // Delete a meal from the plan
  Future<void> deleteMealFromPlan({
    required String householdId,
    required String mealPlanId,
  }) async {
    await _getMealPlanCollection(householdId).doc(mealPlanId).delete();
  }
}
