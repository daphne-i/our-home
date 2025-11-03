import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:homely/features/finance/models/expense_model.dart';
import 'package:homely/features/finance/providers/expense_provider.dart';
import 'package:intl/intl.dart';

// This is the "Add Expense" modal (Section 3.3.1)
class AddExpenseModal extends ConsumerStatefulWidget {
  const AddExpenseModal({super.key});

  @override
  ConsumerState<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends ConsumerState<AddExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedCategory;

  // TODO: In a future phase, load these from Household Settings
  final List<String> _categories = [
    'Groceries',
    'Bills',
    'Utilities',
    'Transport',
    'Eating Out',
    'Entertainment',
    'Shopping',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Default to today's date
    _selectDate(DateTime.now());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _selectDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _dateController.text = DateFormat.yMMMd().format(newDate);
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final initialDate = _selectedDate ?? DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year - 1),
      lastDate: DateTime.now(),
    );

    if (newDate != null) {
      _selectDate(newDate);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        _showErrorSnackBar('Please select a date');
        return;
      }

      final newExpense = ExpenseModel(
        amount: double.parse(_amountController.text.trim()),
        category: _selectedCategory!,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        date: Timestamp.fromDate(_selectedDate!),
        addedBy: '', // Will be filled in by the controller
      );

      try {
        await ref
            .read(expenseControllerProvider.notifier)
            .addExpense(newExpense);
        if (mounted) {
          Navigator.of(context).pop(); // Close the modal on success
        }
      } catch (e) {
        _showErrorSnackBar('An error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(expenseControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add an Expense',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                // --- Amount Field ---
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // --- Category Field ---
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  hint: const Text('Select a category'),
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),
                // --- Date Field ---
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(EvaIcons.calendarOutline),
                  ),
                  onTap: () => _pickDate(context),
                ),
                const SizedBox(height: 16),
                // --- Notes Field ---
                TextFormField(
                  controller: _notesController,
                  decoration:
                      const InputDecoration(labelText: 'Notes (Optional)'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 32),
                // --- Save Button ---
                FilledButton(
                  onPressed: isLoading ? null : _saveExpense,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('SAVE EXPENSE'),
                ),
                // Add bottom padding to push content up when keyboard appears
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
