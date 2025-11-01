import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/providers/firestore_providers.dart';
import 'package:homely/features/household/providers/household_providers.dart';
import 'package:homely/features/tasks/data/task_service.dart';
import 'package:homely/features/tasks/domain/task_model.dart';

// Provider for the TaskService
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.watch(firestoreProvider));
});

// This provider streams the list of tasks for the *current user's household*
final taskListProvider = StreamProvider<List<TaskModel>>((ref) {
  final taskService = ref.watch(taskServiceProvider);
  // Watch the current user's household ID
  final householdId = ref.watch(currentUserModelProvider.select(
    (userModel) => userModel?.householdId,
  ));

  // If the user has no household, return an empty list.
  if (householdId == null) {
    return Stream.value([]);
  }

  // Otherwise, stream the tasks from that household.
  return taskService.getTasksStream(householdId);
});

// StateNotifier for task actions (add, update, delete)
final taskControllerProvider =
    StateNotifierProvider<TaskController, bool>((ref) {
  return TaskController(
    ref.watch(taskServiceProvider),
    ref,
  );
});

class TaskController extends StateNotifier<bool> {
  final TaskService _taskService;
  final Ref _ref;

  TaskController(this._taskService, this._ref) : super(false);

  // Helper to get the current household ID
  String? get _householdId => _ref.read(currentUserModelProvider)?.householdId;

  Future<void> addTask(TaskModel task) async {
    state = true;
    try {
      if (_householdId == null) {
        throw Exception('User is not associated with a household.');
      }
      await _taskService.addTask(householdId: _householdId!, task: task);
    } finally {
      state = false;
    }
  }

  Future<void> toggleTaskStatus(TaskModel task) async {
    // Don't set loading state for this, as it's a quick toggle
    try {
      if (_householdId == null) {
        throw Exception('User is not associated with a household.');
      }
      // Create a copy with the toggled 'isComplete' status
      final updatedTask = task.copyWith(isComplete: !task.isComplete);
      await _taskService.updateTask(
        householdId: _householdId!,
        task: updatedTask,
      );
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      print('Error toggling task: $e');
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    try {
      if (_householdId == null || task.id == null) {
        throw Exception('Cannot delete task.');
      }
      await _taskService.deleteTask(
        householdId: _householdId!,
        taskId: task.id!,
      );
    } catch (e) {
      // Handle error
      print('Error deleting task: $e');
    }
  }
}
