import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/app_theme.dart';
import 'package:homely/features/vault/models/vault_item_model.dart';
import 'package:homely/features/vault/providers/vault_providers.dart';
import 'package:intl/intl.dart';

class AddWarrantyModal extends ConsumerStatefulWidget {
  const AddWarrantyModal({super.key});

  @override
  ConsumerState<AddWarrantyModal> createState() => _AddWarrantyModalState();
}

class _AddWarrantyModalState extends ConsumerState<AddWarrantyModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _purchaseDate;
  DateTime? _expiryDate;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(DateTime? initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final newItem = VaultItemModel(
        name: _nameController.text,
        type: 'Warranty', // Hard-coded for this modal
        purchaseDate:
            _purchaseDate != null ? Timestamp.fromDate(_purchaseDate!) : null,
        expiryDate:
            _expiryDate != null ? Timestamp.fromDate(_expiryDate!) : null,
        // TODO: Add file upload logic here
        // fileName: "receipt.jpg",
        // fileUrl: "gs://...",
      );

      await ref.read(vaultControllerProvider.notifier).addVaultItem(newItem);

      if (mounted) {
        Navigator.pop(context); // Close the modal
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(vaultControllerProvider);

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
                Text('Add Warranty', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTheme.spacingMedium),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // TODO: Add Image Picker button here
                TextButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Upload Receipt (Coming Soon)'),
                  onPressed: () {
                    // File picking logic
                  },
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Purchase Date (Optional)'),
                  subtitle: Text(_purchaseDate == null
                      ? 'None'
                      : DateFormat.yMMMd().format(_purchaseDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await _pickDate(_purchaseDate);
                    if (date != null) setState(() => _purchaseDate = date);
                  },
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Warranty End Date (Optional)'),
                  subtitle: Text(_expiryDate == null
                      ? 'None'
                      : DateFormat.yMMMd().format(_expiryDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await _pickDate(_expiryDate);
                    if (date != null) setState(() => _expiryDate = date);
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
                      : const Text('SAVE WARRANTY'),
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
