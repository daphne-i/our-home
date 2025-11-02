import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/features/tasks/providers/task_providers.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

// TODO: Import models for Meals [cite: 244-252] and Bills [cite: 198-207]

// Provider to keep track of the selected day
final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDay = ref.watch(selectedDayProvider);

    // 1. Fetch data for the selected day
    // We only have tasks for now, but we'll add meals and bills
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner'),
      ),
      body: Column(
        children: [
          // 2. The Calendar Widget [cite: 69]
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (newSelectedDay, newFocusedDay) {
              ref.read(selectedDayProvider.notifier).state = newSelectedDay;
            },
            // Style it to match your app
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

          // 3. The ListView for the selected date [cite: 69-70]
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (allTasks) {
                // Filter tasks for the selected day [cite: 70]
                final tasksForDay = allTasks.where((task) {
                  // Use `isSameDay` from table_calendar
                  return isSameDay(task.dueDate.toDate(), selectedDay);
                }).toList();

                // TODO: Combine this list with Meal Plans and Bills for the selected day [cite: 70]

                if (tasksForDay.isEmpty) {
                  return const Center(
                    child: Text('No items for this day.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasksForDay.length,
                  itemBuilder: (context, index) {
                    final task = tasksForDay[index];
                    // TODO: Create a unified list tile for tasks, meals, and bills
                    return ListTile(
                      leading: const Icon(
                          EvaIcons.clipboardOutline), // Placeholder icon
                      title: Text(task.name),
                      subtitle:
                          Text('Task ${task.isComplete ? "(Completed)" : ""}'),
                      onTap: () {
                        // TODO: Navigate to item's detail screen [cite: 71]
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
