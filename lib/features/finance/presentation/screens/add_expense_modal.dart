import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/app_theme.dart';
import 'package:homely/features/finance/models/expense_model.dart';
import 'package:homely/features/finance/providers/expense_provider.dart';
import 'package:intl/intl.dart';

// --- 1. IMPORT THE NEW CATEGORY PROVIDER ---
import 'package:homely/features/finance/providers/category_providers.dart';

class AddExpenseModal extends ConsumerStatefulWidget {
  const AddExpenseModal({super.key});

  @override
  ConsumerState<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends ConsumerState<AddExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory; // This can now be null initially

  // --- 2. REMOVE THE HARD-CODED LIST ---
  // final List<String> _categories = [ ... ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      final newExpense = ExpenseModel(
        amount: double.tryParse(_amountController.text) ?? 0.0,
        notes: _notesController.text,
        category: _selectedCategory!,
        date: Timestamp.fromDate(_selectedDate),
        addedBy: '', // Controller will fill this
      );

      await ref.read(expenseControllerProvider.notifier).addExpense(newExpense);

      if (mounted) {
        Navigator.pop(context); // Close the modal
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(expenseControllerProvider);

    // --- 3. WATCH THE NEW CATEGORY LIST ---
    final categoriesAsync = ref.watch(categoryListProvider);

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
                Text('Add Expense', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTheme.spacingMedium),

                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                      labelText: 'Amount', prefixText: '₹'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      value == null || double.tryParse(value) == null
                          ? 'Enter a valid amount'
                          : null,
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // --- 4. BUILD THE DROPDOWN FROM THE PROVIDER ---
                categoriesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error loading categories: $err'),
                  data: (categories) {
                    // If the list changed and our selection is no longer valid, reset it
                    if (_selectedCategory != null &&
                        !categories
                            .any((cat) => cat.name == _selectedCategory)) {
                      _selectedCategory = null;
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      hint: const Text('Select Category'),
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: categories
                          .map((category) => DropdownMenuItem(
                              value: category.name, child: Text(category.name)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    );
                  },
                ),
                // --- END OF CHANGE ---

                const SizedBox(height: AppTheme.spacingMedium),

                TextFormField(
                  controller: _notesController,
                  decoration:
                      const InputDecoration(labelText: 'Notes (Optional)'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
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
                      : const Text('SAVE EXPENSE'),
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
