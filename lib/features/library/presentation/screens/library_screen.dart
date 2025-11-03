import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:homely/core/app_theme.dart';
import 'package:homely/features/finance/presentation/screens/finance_hub_screen.dart';
// --- 1. IMPORT THE FULL-PAGE SHOPPING LIST SCREEN ---
import 'package:homely/features/kitchen/presentation/screens/shopping_list_screen.dart';

// --- 2. DEFINE THE CATEGORY DATA ---
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

    // --- 3. BUILD THE LIST OF CATEGORIES FROM DESIGN DOC ---
    final List<LibraryCategory> categories = [
      LibraryCategory(
        title: 'Shopping List',
        icon: EvaIcons.shoppingCartOutline,
        onTap: () {
          // --- 4. NAVIGATE TO THE FULL SCREEN ---
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
          // TODO: Navigate to Recipe Book
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
        icon: EvaIcons.archiveOutline,
        onTap: () {
          // TODO: Navigate to Pantry
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pantry feature coming soon!')));
        },
      ),
      LibraryCategory(
        title: 'The Vault',
        icon: EvaIcons.lockOutline,
        onTap: () {
          // TODO: Navigate to Vault
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vault feature coming soon!')));
        },
      ),
    ];

    // This is the "Library" screen (Tab 2)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      // --- 5. REPLACE BODY WITH A GRIDVIEW ---
      body: GridView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two columns
          crossAxisSpacing: AppTheme.spacingMedium,
          mainAxisSpacing: AppTheme.spacingMedium,
          childAspectRatio: 1.2, // Taller than they are wide
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
