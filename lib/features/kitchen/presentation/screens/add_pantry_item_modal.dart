import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/app_theme.dart';
import 'package:homely/features/kitchen/models/pantry_item_model.dart';
import 'package:homely/features/kitchen/providers/pantry_providers.dart';
import 'package:intl/intl.dart';

class AddPantryItemModal extends ConsumerStatefulWidget {
  const AddPantryItemModal({super.key});

  @override
  ConsumerState<AddPantryItemModal> createState() => _AddPantryItemModalState();
}

class _AddPantryItemModalState extends ConsumerState<AddPantryItemModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final newItem = PantryItemModel(
        name: _nameController.text,
        quantity: _quantityController.text,
        expiryDate:
            _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
      );

      await ref.read(pantryControllerProvider.notifier).addItem(newItem);

      if (mounted) {
        Navigator.pop(context); // Close the modal
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(pantryControllerProvider);

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
                Text('Add Pantry Item', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTheme.spacingMedium),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                      labelText: 'Quantity (e.g., 500g, 2 remaining)'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter a quantity'
                      : null,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Expiry Date (Optional)'),
                  subtitle: Text(
                    _selectedDate == null
                        ? 'None'
                        : DateFormat.yMMMd().format(_selectedDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
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
                      : const Text('ADD ITEM'),
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
