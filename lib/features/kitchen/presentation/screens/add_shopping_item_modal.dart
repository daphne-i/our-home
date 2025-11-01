import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/features/kitchen/providers/shopping_list_providers.dart';

// This is the "Add to Shopping List" modal (Section 3.3.3)
class AddShoppingItemModal extends ConsumerStatefulWidget {
  const AddShoppingItemModal({super.key});

  @override
  ConsumerState<AddShoppingItemModal> createState() =>
      _AddShoppingItemModalState();
}

class _AddShoppingItemModalState extends ConsumerState<AddShoppingItemModal> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _lastAddedItem = '';
  bool _showSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // This matches the "rapid add" design from the doc
  void _addItem() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showErrorDialog('Please enter an item name');
      return;
    }

    final quantity = _quantityController.text.trim();

    try {
      await ref
          .read(shoppingListControllerProvider.notifier)
          .addItem(name, quantity.isNotEmpty ? quantity : null);

      // Show success feedback
      setState(() {
        _lastAddedItem = name;
        _showSuccess = true;
      });

      // Clear fields for next item
      _nameController.clear();
      _quantityController.clear();

      // Hide success message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
          });
        }
      });

      // Set focus back to the name field for rapid adding
      if (mounted) {
        FocusScope.of(context).requestFocus(FocusNode());
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        });
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(shoppingListControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Add to Shopping List',
              style: Theme.of(context).textTheme.titleLarge),

          // Success message
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showSuccess ? 50 : 0,
            child: _showSuccess
                ? Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '"$_lastAddedItem" added!',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 12),
          // --- Item Name Field ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: true, // Auto-focus on this field
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _quantityController,
                  decoration:
                      const InputDecoration(labelText: 'Qty (Optional)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // --- Save Button ---
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLoading ? null : _addItem,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('ADD ITEM'),
            ),
          ),
        ],
      ),
    );
  }
}
