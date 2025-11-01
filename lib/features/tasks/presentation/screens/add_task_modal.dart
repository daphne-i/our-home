import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:homely/features/tasks/domain/task_model.dart';
import 'package:homely/features/tasks/providers/task_providers.dart';
import 'package:intl/intl.dart';

// This is the refactored "Add Task" widget, designed to be shown
// in a modal bottom sheet.
class AddTaskModal extends ConsumerStatefulWidget {
  const AddTaskModal({super.key});

  @override
  ConsumerState<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends ConsumerState<AddTaskModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _assignToController = TextEditingController();
  DateTime? _selectedDate;

  // --- 1. ADD A CONTROLLER FOR THE DATE FIELD ---
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _assignToController.dispose();
    _dateController.dispose(); // --- 2. DISPOSE THE NEW CONTROLLER ---
    super.dispose();
  }

  // Function to show the date picker
  Future<void> _pickDate(BuildContext context) async {
    final initialDate = _selectedDate ?? DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
        // --- 3. SET THE CONTROLLER'S TEXT ---
        _dateController.text = DateFormat.yMMMd().format(newDate);
      });
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

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        _showErrorSnackBar('Please select a due date');
        return;
      }

      final newTask = TaskModel(
        name: _nameController.text.trim(),
        dueDate: Timestamp.fromDate(_selectedDate!),
        assignedTo: _assignToController.text.trim().isNotEmpty
            ? _assignToController.text.trim()
            : null,
      );

      try {
        await ref.read(taskControllerProvider.notifier).addTask(newTask);
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
    final isLoading = ref.watch(taskControllerProvider);
    final theme = Theme.of(context);

    // This widget is wrapped by a SingleChildScrollView in main_app_shell
    // to handle keyboard overflow.
    return SafeArea(
      child: Padding(
        // Add padding to match the "Quick Add" modal
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Title ---
            Text(
              'Add a New Task',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            // --- Form ---
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Task Name Field ---
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Task Name'),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a task name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Due Date Field ---
                  TextFormField(
                    // --- 4. ASSIGN THE CONTROLLER ---
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      // --- 5. USE HINTTEXT AS A PLACEHOLDER ONLY ---
                      hintText: 'Select a date',
                      suffixIcon: Icon(
                        EvaIcons.calendarOutline,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    onTap: () => _pickDate(context),
                  ),
                  const SizedBox(height: 16),

                  // --- Assign To Field ---
                  TextFormField(
                    controller: _assignToController,
                    decoration: const InputDecoration(
                      labelText: 'Assign to (Optional)',
                      hintText: 'Enter name or leave blank',
                    ),
                    // TODO: In a future phase, this should be a dropdown
                    // of household members (from /households/{id}.members)
                  ),
                  const SizedBox(height: 32),

                  // --- Save Button ---
                  FilledButton(
                    onPressed: isLoading ? null : _saveTask,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('SAVE TASK'),
                  ),
                  // Add bottom padding to push content up when keyboard appears
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
