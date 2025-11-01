import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:homely/features/library/presentation/screens/library_screen.dart';
import 'package:homely/features/planner/presentation/screens/planner_screen.dart';
import 'package:homely/features/settings/presentation/screens/settings_screen.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:homely/features/tasks/presentation/screens/add_task_modal.dart';
// --- 1. IMPORT THE NEW ADD EXPENSE MODAL ---
import 'package:homely/features/finance/presentation/screens/add_expense_modal.dart';

class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends ConsumerState<MainAppShell> {
  int _selectedIndex = 0;

  // The list of screens to navigate between
  // NOW 4 screens, including Settings
  static const List<Widget> _widgetOptions = [
    DashboardScreen(),
    PlannerScreen(),
    LibraryScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    // As per design doc, this opens the "Quick Add" modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Make background transparent
      builder: (context) {
        return Container(
          margin:
              const EdgeInsets.symmetric(horizontal: 16), // Add horizontal gaps
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    20, 20, 20, 12), // Reduced bottom padding
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Important: prevents overflow
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Add',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      leading: const Icon(EvaIcons.creditCardOutline),
                      title: const Text('Add Expense'),
                      onTap: () {
                        // --- 2. UPDATE THE ONTAP TO SHOW THE NEW MODAL ---
                        Navigator.pop(context); // Close the "Quick Add" menu
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              child: const AddExpenseModal(),
                            );
                          },
                        );
                        // ----------------------------------------
                      },
                    ),
                    // --- 3. RE-ADD THE "ADD TASK" LISTTILE ---
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      leading: const Icon(EvaIcons.clipboardOutline),
                      title: const Text('Add Task'),
                      onTap: () {
                        Navigator.pop(context); // Close the "Quick Add" menu
                        // Show the AddTaskModal
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              child: const AddTaskModal(),
                            );
                          },
                        );
                      },
                    ),
                    // ------------------------------------
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      leading: const Icon(EvaIcons.shoppingCartOutline),
                      title: const Text('Add to Shopping List'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to Add Shopping Item flow
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Add Shopping Item feature coming soon!')));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // extendBody allows the body to go behind the notched BottomAppBar
      extendBody: true,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        shape: const CircleBorder(), // Ensures perfect circle
        child: const Icon(EvaIcons.plus),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Replaced NavigationBar with BottomAppBar for the "notch"
      bottomNavigationBar: BottomAppBar(
        height: 60, // Reduced height since no labels
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0, // Space around the FAB
        child: Row(
          // Icons are now evenly spaced, with a gap in the middle for the FAB
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildNavItem(
              // Use filled icon for selected, outlined for unselected
              icon: _selectedIndex == 0 ? EvaIcons.home : EvaIcons.homeOutline,
              index: 0,
              theme: theme,
            ),
            _buildNavItem(
              // Use filled icon for selected, outlined for unselected
              icon: _selectedIndex == 1
                  ? EvaIcons.calendar
                  : EvaIcons.calendarOutline,
              index: 1,
              theme: theme,
            ),
            // This is the empty space for the FAB notch
            const SizedBox(width: 48),
            _buildNavItem(
              // Use filled icon for selected, outlined for unselected
              icon: _selectedIndex == 2 ? EvaIcons.book : EvaIcons.bookOutline,
              index: 2,
              theme: theme,
            ),
            _buildNavItem(
              // Use filled icon for selected, outlined for unselected
              icon: _selectedIndex == 3
                  ? EvaIcons.settings
                  : EvaIcons.settingsOutline,
              index: 3,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build a single nav item
  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required ThemeData theme,
  }) {
    // Check if this item is the currently selected one
    final isSelected = _selectedIndex == index;
    // Get better contrast colors for visibility
    final color = isSelected
        ? theme.colorScheme.primary // Selected = Primary (Red)
        : theme.colorScheme.onSurface; // Unselected = High contrast

    return Expanded(
      child: Center(
        child: InkWell(
          onTap: () => _onItemTapped(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 48, // Fixed width to prevent stretching
            height: 48, // Fixed height to maintain square shape
            decoration: isSelected
                ? BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(12), // 0.05
                    borderRadius: BorderRadius.circular(20),
                  )
                : null,
            child: Icon(
              icon,
              color: color,
              size: isSelected ? 34 : 30, // Larger when selected
            ),
          ),
        ),
      ),
    );
  }
}
