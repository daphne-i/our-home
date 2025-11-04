import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:homely/core/app_theme.dart';
import 'package:homely/features/kitchen/presentation/screens/shopping_list_screen.dart';
import 'package:homely/features/finance/presentation/screens/finance_hub_screen.dart';
import 'package:homely/features/kitchen/presentation/screens/pantry_list_screen.dart';

// --- 1. IMPORT THE NEW VAULT SCREEN ---
import 'package:homely/features/vault/presentation/screens/vault_list_screen.dart';
// Note: We'll skip importing the recipe screen for now as requested

// Your existing LibraryCategory class...
class LibraryCategory {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  LibraryCategory({required this.title, required this.icon, this.onTap});
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<LibraryCategory> categories = [
      LibraryCategory(
        title: 'Shopping List',
        icon: EvaIcons.shoppingCartOutline,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ShoppingListScreen(),
            ),
          );
        },
      ),
      LibraryCategory(
        title: 'Recipes',
        icon: EvaIcons.bookOpenOutline,
        onTap: () {
          // TODO: Navigate to RecipeListScreen when ready
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recipes feature coming soon!')));
        },
      ),
      LibraryCategory(
        title: 'Finance Hub',
        icon: EvaIcons.creditCardOutline,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FinanceHubScreen(),
            ),
          );
        },
      ),
      LibraryCategory(
        title: 'Pantry',
        icon: EvaIcons.cubeOutline,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PantryListScreen(),
            ),
          );
        },
      ),
      LibraryCategory(
        title: 'The Vault',
        icon: EvaIcons.archiveOutline,
        onTap: () {
          // --- 2. NAVIGATE TO THE NEW SCREEN ---
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VaultListScreen(),
            ),
          );
        },
      ),
    ];

    // --- (Rest of the file is identical) ---
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacingMedium,
          mainAxisSpacing: AppTheme.spacingMedium,
          childAspectRatio: 1.2,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            child: InkWell(
              onTap: category.onTap,
              borderRadius: AppTheme.cardRadius,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category.title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
