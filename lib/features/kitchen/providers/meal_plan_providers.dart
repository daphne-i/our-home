import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/providers/firestore_providers.dart';
import 'package:homely/features/household/providers/household_providers.dart';
import 'package:homely/features/kitchen/data/meal_plan_service.dart';
import 'package:homely/features/kitchen/models/meal_plan_model.dart';

// 1. Provider for the MealPlanService
final mealPlanServiceProvider = Provider<MealPlanService>((ref) {
  return MealPlanService(ref.watch(firestoreProvider));
});

// 2. Stream provider for the *entire* meal plan
// We stream all meals and let the Planner screen filter by date
final mealPlanProvider = StreamProvider<List<MealPlanModel>>((ref) {
  final mealPlanService = ref.watch(mealPlanServiceProvider);
  final userModel = ref.watch(currentUserModelProvider);
  final householdId = userModel?.householdId;

  if (householdId == null) {
    return Stream.value([]);
  }
  return mealPlanService.getMealPlanStream(householdId);
});

// 3. StateNotifier for meal plan actions
final mealPlanControllerProvider =
    StateNotifierProvider<MealPlanController, bool>((ref) {
  return MealPlanController(
    ref.watch(mealPlanServiceProvider),
    ref,
  );
});

class MealPlanController extends StateNotifier<bool> {
  final MealPlanService _mealPlanService;
  final Ref _ref;

  MealPlanController(this._mealPlanService, this._ref) : super(false);

  String? get _householdId => _ref.read(currentUserModelProvider)?.householdId;

  Future<void> addMealToPlan(MealPlanModel meal) async {
    state = true;
    try {
      if (_householdId == null) {
        throw Exception('User is not in a household.');
      }
      await _mealPlanService.addMealToPlan(
        householdId: _householdId!,
        meal: meal,
      );
    } finally {
      state = false;
    }
  }

  Future<void> deleteMealFromPlan(String mealPlanId) async {
    try {
      if (_householdId == null) {
        throw Exception('User is not in a household.');
      }
      await _mealPlanService.deleteMealFromPlan(
        householdId: _householdId!,
        mealPlanId: mealPlanId,
      );
    } catch (e) {
      print('Error deleting meal: $e');
    }
  }
}
