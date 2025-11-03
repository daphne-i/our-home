import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlanModel {
  final String? id;
  final Timestamp date;
  final String mealType; // e.g., "Breakfast", "Lunch", "Dinner"
  final String recipeId; // For later integration
  final String recipeName; // For display

  MealPlanModel({
    this.id,
    required this.date,
    required this.mealType,
    required this.recipeId,
    required this.recipeName,
  });

  factory MealPlanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealPlanModel(
      id: doc.id,
      date: data['date'] ?? Timestamp.now(),
      mealType: data['mealType'] ?? 'Dinner',
      recipeId: data['recipeId'] ?? '',
      recipeName: data['recipeName'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'mealType': mealType,
      'recipeId': recipeId,
      'recipeName': recipeName,
    };
  }
}
