import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/app_theme.dart';
import 'package:homely/features/kitchen/models/meal_plan_model.dart';
import 'package:homely/features/kitchen/providers/meal_plan_providers.dart';

class AddMealModal extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  const AddMealModal({super.key, required this.selectedDate});

  @override
  ConsumerState<AddMealModal> createState() => _AddMealModalState();
}

class _AddMealModalState extends ConsumerState<AddMealModal> {
  final _formKey = GlobalKey<FormState>();
  final _recipeNameController = TextEditingController();
  String _selectedMealType = 'Dinner';

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  void dispose() {
    _recipeNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final newMeal = MealPlanModel(
        date: Timestamp.fromDate(widget.selectedDate),
        mealType: _selectedMealType,
        recipeId: '', // We'll leave this empty for now
        recipeName: _recipeNameController.text,
      );

      // TODO: This is where the "Kitchen Magic" will start
      // 1. Add meal to plan
      await ref
          .read(mealPlanControllerProvider.notifier)
          .addMealToPlan(newMeal);

      // 2. TODO: Get recipe ingredients (from other app, or manually)
      // 3. TODO: Get pantry list
      // 4. TODO: Compare and add missing to shopping list

      if (mounted) {
        Navigator.pop(context); // Close the modal
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(mealPlanControllerProvider);

    return SingleChildScrollView(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add Meal', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTheme.spacingMedium),
                TextFormField(
                  controller: _recipeNameController,
                  decoration: const InputDecoration(labelText: 'Recipe Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                DropdownButtonFormField<String>(
                  value: _selectedMealType,
                  decoration: const InputDecoration(labelText: 'Meal Type'),
                  items: _mealTypes
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedMealType = value);
                    }
                  },
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ADD TO PLAN'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
