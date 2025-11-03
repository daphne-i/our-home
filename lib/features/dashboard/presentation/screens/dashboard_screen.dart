import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/app_theme.dart';
import 'package:homely/features/tasks/providers/task_providers.dart';
import 'package:homely/features/tasks/domain/task_model.dart';
import 'package:homely/features/finance/providers/expense_provider.dart';
import 'package:homely/features/kitchen/providers/shopping_list_providers.dart';
import 'package:intl/intl.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:homely/features/kitchen/presentation/screens/view_shopping_list_modal.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onViewAllTasks;

  const DashboardScreen({super.key, this.onViewAllTasks});

  @override
  Widget build(BuildContext context) {
    // This is the main "Dashboard" screen (Tab 0)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Morning!'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          // 3. WATCH ALL OUR PROVIDERS
          final tasksAsync = ref.watch(taskListProvider);
          final monthlySpending = ref.watch(monthlySpendingProvider);
          final shoppingListAsync = ref.watch(shoppingListProvider);
          final currencyFormat =
              NumberFormat.currency(locale: 'en_IN', symbol: '₹');
          // TODO: Load this from household settings in the future
          const monthlyBudget = 20000.00;

          // --- 4. PREPARE THE GRID CARDS ---
          final List<Widget> gridCards = [
            // --- CARD 1: FINANCE ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending', // Shorter title for grid
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
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
                                fontSize: 24, // Smaller for grid
                              ),
                        ),
                      ],
                    ),
                    Text(
                      '/ ${currencyFormat.format(monthlyBudget)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTheme.spacingSmall),
                      child: LinearProgressIndicator(
                        value:
                            (monthlySpending / monthlyBudget).clamp(0.0, 1.0),
                        minHeight: 8, // Thinner for grid
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- CARD 2: SHOPPING LIST ---
            shoppingListAsync.when(
              loading: () =>
                  const SizedBox.shrink(), // Don't show card if loading
              error: (err, stack) => const SizedBox.shrink(), // Or if error
              data: (items) {
                final uncheckedItems =
                    items.where((item) => !item.isChecked).length;
                // Only show the card if there are items on the list
                if (uncheckedItems == 0) {
                  return const SizedBox.shrink();
                }
                // --- 2. WRAP CARD IN INKWELL ---
                return InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => const ViewShoppingListModal(),
                    );
                  },
                  borderRadius: AppTheme.cardRadius,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      // Simplified layout for a grid
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shopping', // Shorter title
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          Icon(
                            EvaIcons.shoppingCartOutline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32, // Large icon
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),
                          Text(
                            '$uncheckedItems items', // Simpler text
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ];

          // Filter out any empty SizedBox widgets
          final visibleGridCards =
              gridCards.where((card) => card is! SizedBox).toList();

          // --- 5. USE A CUSTOMSCROLLVIEW FOR HYBRID LAYOUT ---
          return CustomScrollView(
            // --- FIX: Removed padding parameter ---
            slivers: [
              // --- FIX: Added SliverPadding ---
              SliverPadding(
                padding: const EdgeInsets.all(AppTheme.spacingSmall),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two columns
                    mainAxisSpacing: AppTheme.spacingSmall,
                    crossAxisSpacing: AppTheme.spacingSmall,
                    childAspectRatio: 1.1, // Aspect ratio for grid items
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => visibleGridCards[index],
                    childCount: visibleGridCards.length,
                  ),
                ),
              ),

              // --- 7. A SLIVERLIST FOR THE FULL-WIDTH TASK CARD ---
              // --- FIX: Added SliverPadding ---
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingSmall,
                  0,
                  AppTheme.spacingSmall,
                  AppTheme.spacingSmall,
                ),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    // --- FIX: Removed extra margin ---
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Due Today',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              TextButton(
                                onPressed: onViewAllTasks,
                                child: const Text('View All'),
                              ),
                            ],
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
                              // Filter tasks to show only those due today
                              final now = DateTime.now();
                              final today =
                                  DateTime(now.year, now.month, now.day);

                              final todayTasks = tasks.where((task) {
                                final taskDate = task.dueDate.toDate();
                                final taskDateOnly = DateTime(taskDate.year,
                                    taskDate.month, taskDate.day);
                                return taskDateOnly.isAtSameMomentAs(today);
                              }).toList();

                              // 5. CHECK IF LIST IS EMPTY
                              if (todayTasks.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('No tasks due today!'),
                                  ),
                                );
                              }
                              // 6. DISPLAY THE LIST OF TODAY'S TASKS
                              return Column(
                                children: todayTasks
                                    .map((task) => _TaskTile(task: task))
                                    .toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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

// --- 8. HELPER WIDGET FOR A SINGLE TASK TILE (This was missing) ---
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

    String subtitleText = dueDate;
    if (task.assignedTo != null && task.assignedTo!.isNotEmpty) {
      subtitleText += " • ${task.assignedTo}";
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: task.isComplete,
        activeColor: theme.colorScheme.primary,
        checkColor: theme.colorScheme.onPrimary,
        side: BorderSide(
          color: theme.colorScheme.onSurface.withOpacity(0.4),
          width: 2,
        ),
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
              ? theme.colorScheme.onSurface.withOpacity(0.5)
              : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitleText,
        style: textTheme.bodySmall?.copyWith(
          color: dueDate == 'Overdue'
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          EvaIcons.trash2Outline,
          size: 20,
          color: theme.colorScheme.error,
        ),
        onPressed: () {
          // Delete the task
          ref.read(taskControllerProvider.notifier).deleteTask(task);
        },
      ),
    );
  }
}
