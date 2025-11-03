import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/features/kitchen/models/pantry_item_model.dart';
import 'package:homely/features/kitchen/presentation/screens/add_pantry_item_modal.dart';
import 'package:homely/features/kitchen/providers/pantry_providers.dart';
import 'package:intl/intl.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class PantryListScreen extends ConsumerWidget {
  const PantryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantryAsync = ref.watch(pantryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantry'),
      ),
      body: pantryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Your pantry is empty.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _PantryItemTile(item: item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddPantryItemModal(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PantryItemTile extends ConsumerWidget {
  final PantryItemModel item;
  const _PantryItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    String subtitle = 'Quantity: ${item.quantity}';
    Color? expiryColor;

    if (item.expiryDate != null) {
      final expiry = item.expiryDate!.toDate();
      final now = DateTime.now();
      final difference = expiry.difference(now).inDays;

      if (difference < 0) {
        subtitle += ' • Expired';
        expiryColor = theme.colorScheme.error;
      } else if (difference <= 7) {
        subtitle += ' • Expires in $difference days';
        expiryColor = theme.colorScheme.tertiary; // Or another warning color
      } else {
        subtitle += ' • Expires ${DateFormat.yMMMd().format(expiry)}';
      }
    }

    return ListTile(
      title: Text(item.name),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: expiryColor),
      ),
      trailing: IconButton(
        icon: Icon(EvaIcons.trash2Outline,
            color: theme.colorScheme.error, size: 20),
        onPressed: () {
          // Simple delete confirmation
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Item'),
              content: Text('Are you sure you want to delete ${item.name}?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    ref
                        .read(pantryControllerProvider.notifier)
                        .deleteItem(item.id!);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
      onTap: () {
        // TODO: Implement edit modal
        // For now, we can just show the add modal with pre-filled data (later)
      },
    );
  }
}
