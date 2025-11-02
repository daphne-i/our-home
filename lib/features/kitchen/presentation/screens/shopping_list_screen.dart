import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:homely/features/kitchen/models/shopping_list_item_model.dart';
import 'package:homely/features/kitchen/providers/shopping_list_providers.dart';

// This is the full-page "Shopping List" screen (Section 3.6)
class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final listAsync = ref.watch(shoppingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          // "Clear Checked Items" button
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Clear checked items',
            onPressed: () {
              // Show a confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Checked Items?'),
                  content: const Text(
                      'This will permanently delete all checked items from your list.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        ref
                            .read(shoppingListControllerProvider.notifier)
                            .clearCheckedItems();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    EvaIcons.shoppingBagOutline,
                    size: 60,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your shopping list is empty!',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add items from the "+" button on the dashboard.'),
                ],
              ),
            );
          }

          // Separate lists for checked and unchecked items
          final uncheckedItems = items.where((i) => !i.isChecked).toList();
          final checkedItems = items.where((i) => i.isChecked).toList();

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // --- UNCHECKED ITEMS ---
              ...uncheckedItems.map((item) => ShoppingListItemTile(item: item)),

              // --- "CHECKED" DIVIDER ---
              if (checkedItems.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      Text(
                        'CHECKED (${checkedItems.length})',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          indent: 16,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),

              // --- CHECKED ITEMS ---
              ...checkedItems.map((item) => ShoppingListItemTile(item: item)),
            ],
          );
        },
      ),
    );
  }
}

// Helper widget for a single list item
class ShoppingListItemTile extends ConsumerWidget {
  final ShoppingListItemModel item;
  const ShoppingListItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ListTile(
      onTap: () {
        ref
            .read(shoppingListControllerProvider.notifier)
            .toggleItemStatus(item);
      },
      leading: Checkbox(
        value: item.isChecked,
        activeColor: theme.colorScheme.primary,
        checkColor: theme.colorScheme.onPrimary,
        side: BorderSide(
          color: theme.colorScheme.onSurface.withOpacity(0.4),
          width: 2,
        ),
        onChanged: (value) {
          ref
              .read(shoppingListControllerProvider.notifier)
              .toggleItemStatus(item);
        },
      ),
      title: Text(
        item.name,
        style: textTheme.bodyLarge?.copyWith(
          decoration:
              item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
          color: item.isChecked
              ? theme.colorScheme.onSurface.withOpacity(0.5)
              : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: item.quantity != null
          ? Text(
              item.quantity!,
              style: textTheme.bodySmall?.copyWith(
                color: item.isChecked
                    ? theme.colorScheme.onSurface.withOpacity(0.4)
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            )
          : null,
      trailing: IconButton(
        icon: Icon(
          EvaIcons.trash2Outline,
          size: 20,
          color: theme.colorScheme.error,
        ),
        onPressed: () {
          // No confirmation, just delete
          ref.read(shoppingListControllerProvider.notifier).deleteItem(item);
        },
      ),
    );
  }
}
