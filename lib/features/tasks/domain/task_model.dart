import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String? id;
  final String name;
  final Timestamp dueDate;
  final bool isComplete;
  final String? assignedTo;
  // --- 1. ADD NEW FIELDS FROM SCHEMA ---
  final bool isRepeating;
  final String type; // e.g., "Task", "Chore", "Bill", "Reminder"
  final String? sourceId; // e.g., the subscriptionId

  TaskModel({
    this.id,
    required this.name,
    required this.dueDate,
    this.isComplete = false,
    this.assignedTo,
    // --- 2. INITIALIZE NEW FIELDS ---
    this.isRepeating = false,
    this.type = 'Task', // Default to "Task"
    this.sourceId,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      name: data['name'] ?? '',
      dueDate: data['dueDate'] ?? Timestamp.now(),
      isComplete: data['isComplete'] ?? false,
      assignedTo: data['assignedTo'],
      // --- 3. HYDRATE NEW FIELDS ---
      isRepeating: data['isRepeating'] ?? false,
      type: data['type'] ?? 'Task',
      sourceId: data['sourceId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'dueDate': dueDate,
      'isComplete': isComplete,
      'assignedTo': assignedTo,
      // --- 4. SAVE NEW FIELDS ---
      'isRepeating': isRepeating,
      'type': type,
      'sourceId': sourceId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? name,
    Timestamp? dueDate,
    bool? isComplete,
    String? assignedTo,
    bool? isRepeating,
    String? type,
    String? sourceId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dueDate: dueDate ?? this.dueDate,
      isComplete: isComplete ?? this.isComplete,
      assignedTo: assignedTo ?? this.assignedTo,
      isRepeating: isRepeating ?? this.isRepeating,
      type: type ?? this.type,
      sourceId: sourceId ?? this.sourceId,
    );
  }
}
