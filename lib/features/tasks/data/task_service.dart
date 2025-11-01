import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homely/features/tasks/domain/task_model.dart';

// This service handles all Firestore operations for the tasks collection.
class TaskService {
  final FirebaseFirestore _firestore;

  TaskService(this._firestore);

  // Get the path to the tasks subcollection for a given household
  CollectionReference _tasksCollection(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('tasks');
  }

  // Stream a list of tasks for a household
  Stream<List<TaskModel>> getTasksStream(String householdId) {
    // Order by due date, oldest first
    return _tasksCollection(householdId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    });
  }

  // Add a new task
  Future<void> addTask({
    required String householdId,
    required TaskModel task,
  }) async {
    await _tasksCollection(householdId).add(task.toFirestore());
  }

  // Update a task (e.g., toggle completion)
  Future<void> updateTask({
    required String householdId,
    required TaskModel task,
  }) async {
    if (task.id == null) {
      throw Exception('Cannot update task with null ID');
    }
    await _tasksCollection(householdId).doc(task.id).update(task.toFirestore());
  }

  // Delete a task
  Future<void> deleteTask({
    required String householdId,
    required String taskId,
  }) async {
    await _tasksCollection(householdId).doc(taskId).delete();
  }
}
