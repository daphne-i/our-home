import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/app_theme.dart';
import 'package:homely/features/finance/models/subscription_model.dart';
import 'package:homely/features/finance/providers/expense_provider.dart';
import 'package:intl/intl.dart';

class AddSubscriptionModal extends ConsumerStatefulWidget {
  const AddSubscriptionModal({super.key});

  @override
  ConsumerState<AddSubscriptionModal> createState() =>
      _AddSubscriptionModalState();
}

class _AddSubscriptionModalState extends ConsumerState<AddSubscriptionModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCycle = 'Monthly';

  final List<String> _billingCycles = [
    'Monthly',
    'Quarterly',
    'Yearly',
    'One-time',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
      final name = _nameController.text;
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      final newSubscription = SubscriptionModel(
        name: name,
        amount: amount,
        billingCycle: _selectedCycle,
        nextDueDate: Timestamp.fromDate(_selectedDate),
      );

      // Call the controller to add the subscription and create the task
      await ref
          .read(subscriptionControllerProvider.notifier)
          .addSubscription(newSubscription);

      if (mounted) {
        Navigator.pop(context); // Close the modal
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(subscriptionControllerProvider);

    return SingleChildScrollView(
      child: Padding(
        // Handle keyboard overlap
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
                Text('Add Subscription', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTheme.spacingMedium),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // Amount
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

                // Billing Cycle
                DropdownButtonFormField<String>(
                  value: _selectedCycle,
                  decoration: const InputDecoration(labelText: 'Billing Cycle'),
                  items: _billingCycles
                      .map((cycle) =>
                          DropdownMenuItem(value: cycle, child: Text(cycle)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCycle = value);
                    }
                  },
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // Next Due Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Next Due Date'),
                  subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // Submit Button
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('SAVE SUBSCRIPTION'),
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
