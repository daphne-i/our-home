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

// --- 1. IMPORT MEAL PLAN PROVIDER & MODEL ---
import 'package:homely/features/kitchen/providers/meal_plan_providers.dart';
import 'package:homely/features/kitchen/models/meal_plan_model.dart';

// --- UPDATE THE DASHBOARD WIDGET ---
class DashboardScreen extends StatelessWidget {
  // Add this to accept the navigation callback from main_app_shell
  final VoidCallback onViewAllTasks;

  const DashboardScreen({super.key, required this.onViewAllTasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Morning!'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final tasksAsync = ref.watch(taskListProvider);
          final monthlySpending = ref.watch(monthlySpendingProvider);
          final shoppingListAsync = ref.watch(shoppingListProvider);
          final currencyFormat =
              NumberFormat.currency(locale: 'en_IN', symbol: '₹');
          const monthlyBudget = 20000.00; // TODO: Load from household

          // --- 2. WATCH THE NEW DINNER PROVIDER ---
          final todaysDinner = ref.watch(todaysDinnerProvider);

          final List<Widget> gridCards = [
            // --- CARD 1: FINANCE (Existing) ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending',
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
                                fontSize: 24,
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
                        minHeight: 8,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 3. ADD MEAL PLANNER CARD [cite: 63-64] ---
            if (todaysDinner != null) // Only show the card if dinner is planned
              InkWell(
                onTap: () {
                  // TODO: Navigate to Recipe Detail Screen [cite: 64]
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Recipe details coming soon!')),
                  );
                },
                borderRadius: AppTheme.cardRadius,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tonight's Dinner",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        Icon(
                          EvaIcons.bellOutline, // Icon from Planner
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Text(
                          todaysDinner.recipeName, // The recipe name!
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // --- END OF NEW CARD ---

            // --- CARD 4: SHOPPING LIST (Existing) ---
            shoppingListAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
              data: (items) {
                final uncheckedItems =
                    items.where((item) => !item.isChecked).length;
                if (uncheckedItems == 0) {
                  return const SizedBox.shrink();
                }
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shopping',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          Icon(
                            EvaIcons.shoppingCartOutline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),
                          Text(
                            '$uncheckedItems items',
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

          // Filter out any nulls or SizedBox widgets
          final visibleGridCards =
              gridCards.whereType<Widget>().toList(); // Simpler filter

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppTheme.spacingSmall),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppTheme.spacingSmall,
                    crossAxisSpacing: AppTheme.spacingSmall,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => visibleGridCards[index],
                    childCount: visibleGridCards.length,
                  ),
                ),
              ),

              // --- TASK CARD (Existing, but with update) ---
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingSmall,
                  0,
                  AppTheme.spacingSmall,
                  AppTheme.spacingSmall,
                ),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- 4. ADD "VIEW ALL" BUTTON ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tasks & Chores',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              TextButton(
                                onPressed: onViewAllTasks, // Use the callback
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),
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
                              // --- 5. FILTER TASKS FOR "TODAY" ---
                              final now = DateTime.now();
                              final tasksToday = tasks.where((task) {
                                final dueDate = task.dueDate.toDate();
                                return !task.isComplete &&
                                    (dueDate.day == now.day &&
                                        dueDate.month == now.month &&
                                        dueDate.year == now.year);
                              }).toList();
                              // --- END OF FILTER ---

                              if (tasksToday.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('No tasks due today!'),
                                  ),
                                );
                              }
                              return Column(
                                children: tasksToday
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

// --- (TaskTile widget is unchanged) ---
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
    // --- 6. UPDATE SUBTITLE TO SHOW TASK TYPE ---
    if (task.type != 'Task') {
      subtitleText += " • ${task.type}"; // e.g., "Today • Bill"
    }
    // --- END OF CHANGE ---

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
          ref.read(taskControllerProvider.notifier).deleteTask(task);
        },
      ),
    );
  }
}
