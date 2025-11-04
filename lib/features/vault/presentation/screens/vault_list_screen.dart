import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/features/vault/models/vault_item_model.dart';
import 'package:homely/features/vault/presentation/screens/add_warranty_modal.dart';
import 'package:homely/features/vault/providers/vault_providers.dart';
import 'package:intl/intl.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class VaultListScreen extends ConsumerWidget {
  const VaultListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultItemsAsync = ref.watch(vaultListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Vault'),
      ),
      body: vaultItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
                child:
                    Text('Your vault is empty. Add a warranty or document.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _VaultItemTile(item: item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // For now, the FAB only adds Warranties as per the design [cite: 95]
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddWarrantyModal(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _VaultItemTile extends ConsumerWidget {
  final VaultItemModel item;
  const _VaultItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    IconData icon;
    String subtitle = 'Document';

    if (item.type == 'Warranty') {
      icon = EvaIcons.shieldOutline;
      subtitle = 'Warranty';
      if (item.expiryDate != null) {
        final expiry = item.expiryDate!.toDate();
        final now = DateTime.now();
        if (expiry.isBefore(now)) {
          subtitle += ' (Expired)';
        } else {
          subtitle += ' (Expires ${DateFormat.yMd().format(expiry)})';
        }
      }
    } else {
      icon = EvaIcons.fileTextOutline;
    }

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(item.name),
      subtitle: Text(subtitle),
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
                        .read(vaultControllerProvider.notifier)
                        .deleteVaultItem(item.id!);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
      onTap: () {
        // TODO: Implement edit/view modal
      },
    );
  }
}
