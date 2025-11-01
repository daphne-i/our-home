import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/app_theme.dart';
import 'package:homely/features/tasks/providers/task_providers.dart';
import 'package:homely/features/tasks/domain/task_model.dart';
// --- 1. IMPORT FINANCE PROVIDERS ---
import 'package:homely/features/finance/providers/expense_provider.dart';
import 'package:intl/intl.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the main "Dashboard" screen (Tab 0)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Morning!'),
      ),
      // --- 2. CHANGE BODY TO A Consumer WIDGET ---
      body: Consumer(
        builder: (context, ref, child) {
          // 3. WATCH THE TASK LIST PROVIDER
          final tasksAsync = ref.watch(taskListProvider);
          // --- 4. WATCH THE FINANCE PROVIDER ---
          final monthlySpending = ref.watch(monthlySpendingProvider);
          // --- 5. CREATE A FORMATTER ---
          final currencyFormat =
              NumberFormat.currency(locale: 'en_IN', symbol: '₹');
          // TODO: Load this from household settings in the future
          const monthlyBudget = 20000.00;

          return ListView(
            // Use less padding to make cards fit better
            padding: const EdgeInsets.all(AppTheme.spacingSmall / 2),
            children: [
              // --- 6. ADD THE "FINANCE" CARD ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Month\'s Spending',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      // Spending Text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            currencyFormat.format(monthlySpending),
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 28,
                                ),
                          ),
                          const SizedBox(width: AppTheme.spacingSmall),
                          Text(
                            '/ ${currencyFormat.format(monthlyBudget)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  // --- FIX 1: INCREASED CONTRAST ---
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                  // --- END FIX ---
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      // Budget Bar
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.spacingSmall),
                        child: LinearProgressIndicator(
                          value:
                              (monthlySpending / monthlyBudget).clamp(0.0, 1.0),
                          minHeight: 12,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // --- 7. THE "TASKS & CHORES" CARD ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasks & Chores',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      // Use .when to handle loading/error/data states
                      tasksAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Error: ${err.toString()}'),
                          ),
                        ),
                        data: (tasks) {
                          // 5. CHECK IF LIST IS EMPTY
                          if (tasks.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No tasks due. Add one!'),
                              ),
                            );
                          }
                          // 6. DISPLAY THE LIST OF TASKS
                          return Column(
                            children: tasks
                                .map((task) => _TaskTile(task: task))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- 8. HELPER WIDGET FOR A SINGLE TASK TILE ---
class _TaskTile extends ConsumerWidget {
  final TaskModel task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Format the due date
    String dueDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = task.dueDate.toDate();
    final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

    if (taskDateOnly.isBefore(today)) {
      dueDate = 'Overdue';
    } else if (taskDateOnly.isAtSameMomentAs(today)) {
      dueDate = 'Today';
    } else if (taskDateOnly.isAtSameMomentAs(tomorrow)) {
      dueDate = 'Tomorrow';
    } else {
      dueDate = DateFormat.MMMd().format(taskDate); // e.g., "Nov 10"
    }

    // --- FIX 1: BUILD THE SUBTITLE STRING ---
    String subtitleText = dueDate;
    if (task.assignedTo != null && task.assignedTo!.isNotEmpty) {
      subtitleText += " • ${task.assignedTo}";
    }
    // --- END FIX 1 ---

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: task.isComplete,
        // --- FIX 2: IMPROVED CHECKBOX COLORS ---
        activeColor: theme.colorScheme.primary,
        checkColor: theme.colorScheme.onPrimary,
        side: BorderSide(
          color: theme.colorScheme.onSurface.withOpacity(0.4),
          width: 2,
        ),
        // --- END FIX ---
        onChanged: (bool? value) {
          // Toggle the task's completion status
          ref.read(taskControllerProvider.notifier).toggleTaskStatus(task);
        },
      ),
      title: Text(
        task.name,
        style: textTheme.bodyLarge?.copyWith(
          decoration: task.isComplete
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          color: task.isComplete
              ? theme.colorScheme.onSurface
                  .withOpacity(0.5) // <-- FIX: Increased contrast
              : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        // --- USE NEW SUBTITLE STRING ---
        subtitleText,
        style: textTheme.bodySmall?.copyWith(
          // --- FIX 2: MAKE TEXT MORE VISIBLE ---
          color: dueDate == 'Overdue'
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface.withOpacity(0.7),
          // --- END FIX 2 ---
        ),
      ),
      trailing: IconButton(
        // --- FIX 3: RESTORED RED DELETE ICON ---
        icon: Icon(
          EvaIcons.trash2Outline,
          size: 20,
          color: theme.colorScheme.error,
        ),
        // --- END FIX ---
        onPressed: () {
          // Delete the task
          ref.read(taskControllerProvider.notifier).deleteTask(task);
        },
      ),
    );
  }
}
