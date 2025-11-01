import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/app_theme.dart';
// --- 1. IMPORT THE NEW TASK PROVIDERS ---
import 'package:homely/features/tasks/providers/task_providers.dart';
import 'package:homely/features/tasks/domain/task_model.dart';
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

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingSmall / 2),
            children: [
              // --- 4. ADD THE "TASKS & CHORES" CARD ---
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

                      // 5. USE .when() TO HANDLE LOADING/ERROR/DATA
                      tasksAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, stack) => Center(
                          child: Text('Error: $err'),
                        ),
                        data: (List<TaskModel> tasks) {
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
              // We will build the other Dashboard Cards here later
            ],
          );
        },
      ),
    );
  }
}

// --- 7. HELPER WIDGET FOR A SINGLE TASK TILE ---
class _TaskTile extends ConsumerWidget {
  final TaskModel task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Format the due date
    final String dueDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = task.dueDate.toDate();

    if (taskDate.isBefore(today)) {
      dueDate = 'Overdue';
    } else if (taskDate.year == today.year &&
        taskDate.month == today.month &&
        taskDate.day == today.day) {
      dueDate = 'Today';
    } else if (taskDate.year == tomorrow.year &&
        taskDate.month == tomorrow.month &&
        taskDate.day == tomorrow.day) {
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
        onChanged: (bool? value) {
          // Toggle the task's completion status
          ref.read(taskControllerProvider.notifier).toggleTaskStatus(task);
        },
      ),
      title: Text(
        task.name,
        style: textTheme.bodyMedium?.copyWith(
          decoration: task.isComplete
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          color: task.isComplete
              ? theme.colorScheme.onSurfaceVariant
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
        icon: const Icon(EvaIcons.trash2Outline),
        iconSize: 20,
        color: theme.colorScheme.error,
        onPressed: () {
          // Delete the task
          ref.read(taskControllerProvider.notifier).deleteTask(task);
        },
      ),
    );
  }
}
