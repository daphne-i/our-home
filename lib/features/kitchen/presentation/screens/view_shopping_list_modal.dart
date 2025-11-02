import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:homely/features/kitchen/models/shopping_list_item_model.dart';
import 'package:homely/features/kitchen/providers/shopping_list_providers.dart';

// This is a "quick view" modal of the shopping list, launched from the dashboard.
class ViewShoppingListModal extends ConsumerWidget {
  const ViewShoppingListModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final listAsync = ref.watch(shoppingListProvider);

    return Container(
      // Set a max height so it doesn't take over the whole screen
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Text(
            'Shopping List',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          // Scrollable List
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Error: ${err.toString()}')),
              data: (items) {
                if (items.isEmpty) {
                  // This case should rarely be hit since the
                  // dashboard card wouldn't be visible, but it's good practice.
                  return Center(
                    child: Text(
                      'Your shopping list is empty!',
                      style: theme.textTheme.headlineSmall,
                    ),
                  );
                }

                // Separate lists for checked and unchecked items
                final uncheckedItems =
                    items.where((i) => !i.isChecked).toList();
                final checkedItems = items.where((i) => i.isChecked).toList();

                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    // --- UNCHECKED ITEMS ---
                    ...uncheckedItems
                        .map((item) => ShoppingListItemTile(item: item)),

                    // --- "CHECKED" DIVIDER ---
                    if (checkedItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Row(
                          children: [
                            Text(
                              'CHECKED (${checkedItems.length})',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
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
                    ...checkedItems
                        .map((item) => ShoppingListItemTile(item: item)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for a single list item (re-used from shopping_list_screen.dart)
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
