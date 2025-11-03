import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/features/kitchen/models/meal_plan_model.dart';
import 'package:homely/features/kitchen/providers/meal_plan_providers.dart';
import 'package:homely/features/tasks/domain/task_model.dart';
import 'package:homely/features/tasks/providers/task_providers.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

// Provider to keep track of the selected day
final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

// A new class to hold our combined planner items
enum PlannerItemType { task, meal, bill }

class PlannerItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final PlannerItemType type;
  final dynamic originalItem; // The TaskModel, MealPlanModel, etc.

  PlannerItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    required this.originalItem,
  });
}

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDay = ref.watch(selectedDayProvider);

    final tasksAsync = ref.watch(taskListProvider);
    final mealsAsync = ref.watch(mealPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
      ),
      body: Column(
        children: [
          // The Calendar Widget (no changes)
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (newSelectedDay, newFocusedDay) {
              ref.read(selectedDayProvider.notifier).state = newSelectedDay;
            },
            headerStyle: HeaderStyle(
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMMM(locale).format(date),
              titleTextStyle: theme.textTheme.titleMedium!,
              formatButtonVisible: false,
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: theme.colorScheme.primary),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: theme.colorScheme.primary),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface),
              weekendTextStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
              outsideTextStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.4)),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _buildPlannerList(
                context, ref, selectedDay, tasksAsync, mealsAsync),
          ),
        ],
      ),
    );
  }

  // (Rest of the file is the same)
  Widget _buildPlannerList(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDay,
    AsyncValue<List<TaskModel>> tasksAsync,
    AsyncValue<List<MealPlanModel>> mealsAsync,
  ) {
    // Show a loading indicator if *any* provider is loading
    if (tasksAsync.isLoading || mealsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Combine all data into a single list
    final List<PlannerItem> itemsForDay = [];

    // Add Tasks
    final tasks = tasksAsync.valueOrNull ?? [];
    for (final task in tasks) {
      if (isSameDay(task.dueDate.toDate(), selectedDay)) {
        itemsForDay.add(PlannerItem(
          title: task.name,
          subtitle: task.type, // "Task", "Bill", etc.
          icon: task.type == 'Bill'
              ? EvaIcons.creditCardOutline
              : EvaIcons.clipboardOutline,
          type: PlannerItemType.task,
          originalItem: task,
        ));
      }
    }

    // Add Meals
    final meals = mealsAsync.valueOrNull ?? [];
    for (final meal in meals) {
      if (isSameDay(meal.date.toDate(), selectedDay)) {
        itemsForDay.add(PlannerItem(
          title: meal.recipeName,
          subtitle: meal.mealType, // "Dinner", "Lunch", etc.
          icon: EvaIcons.bellOutline, // Using the FAB icon
          type: PlannerItemType.meal,
          originalItem: meal,
        ));
      }
    }

    if (itemsForDay.isEmpty) {
      return const Center(
        child: Text('No items for this day.'),
      );
    }

    // Sort the list (e.g., by type)
    itemsForDay.sort((a, b) => a.subtitle.compareTo(b.subtitle));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemsForDay.length,
      itemBuilder: (context, index) {
        final item = itemsForDay[index];
        return ListTile(
          leading: Icon(item.icon),
          title: Text(item.title),
          subtitle: Text(item.subtitle),
          onTap: () {
            // TODO: Navigate to item's detail screen
          },
        );
      },
    );
  }
}
