import 'package:flutter/material.dart';
import 'package:homely/core/app_theme.dart';
import 'package:homely/features/kitchen/models/meal_plan_model.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class RecipeDetailScreen extends StatelessWidget {
  // We'll pass the MealPlanModel for now
  final MealPlanModel meal;

  const RecipeDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(meal.recipeName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Use extendBodyBehindAppBar to let the image go under the app bar
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. IMAGE PLACEHOLDER ---
            Container(
              height: 300,
              color: theme.colorScheme.secondaryContainer,
              child: Center(
                child: Icon(
                  EvaIcons.imageOutline,
                  size: 100,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                // TODO: When you have a recipe model, you'd show the image here:
                // child: Image.network(recipe.photoUrl, fit: BoxFit.cover),
              ),
            ),

            // --- 2. RECIPE INFO ---
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.recipeName,
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  // Prep & Cook Time (Placeholder)
                  Row(
                    children: [
                      Icon(EvaIcons.clockOutline,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Text('Prep: 15 min', style: theme.textTheme.bodyMedium),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Icon(EvaIcons.thermometerOutline,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Text('Cook: 30 min', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const Divider(height: 32),

                  // Ingredients (Placeholder)
                  Text('Ingredients', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppTheme.spacingSmall),
                  const Text('• 500g Chicken'),
                  const Text('• 2 Onions'),
                  const Text('• 1 tbsp Garlic'),
                  const Text('• 1 tbsp Ginger'),
                  const Text('• 400ml Coconut Milk'),
                  const Text('• 2 tbsp Curry Powder'),
                  const Divider(height: 32),

                  // Instructions (Placeholder)
                  Text('Instructions', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppTheme.spacingSmall),
                  const Text('1. Sauté onions, garlic, and ginger.'),
                  const Text('2. Add chicken and brown.'),
                  const Text('3. Add spices and coconut milk.'),
                  const Text('4. Simmer for 20 minutes.'),
                ],
              ),
            ),
          ],
        ),
      ),
      // --- 3. "ADD TO MEAL PLAN" BUTTON (from design) ---
      // We can hide this for now, or make it navigate back
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: FilledButton(
          onPressed: () {
            // This button's function is TBD
            // For now, it just closes the screen
            Navigator.pop(context);
          },
          child: const Text('ADD TO MEAL PLAN (Placeholder)'),
        ),
      ),
    );
  }
}
