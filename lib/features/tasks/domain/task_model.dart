import 'package:cloud_firestore/cloud_firestore.dart';

// This is our custom task model, based on the Firestore Data Structure
// in your design document (Section 3. Operations Module).
// Path: /households/{householdId}/tasks/{taskId}
class TaskModel {
  final String? id; // Nullable for new tasks not yet in Firestore
  final String name;
  final Timestamp dueDate;
  final bool isComplete;
  final bool isRepeating;
  final String type;
  final String? assignedTo; // User UID
  final String? sourceId; // e.g., subscription_id

  TaskModel({
    this.id,
    required this.name,
    required this.dueDate,
    this.isComplete = false,
    this.isRepeating = false,
    this.type = 'Task', // Default type
    this.assignedTo,
    this.sourceId,
  });

  // Helper method to create a copy with modified fields
  TaskModel copyWith({
    String? id,
    String? name,
    Timestamp? dueDate,
    bool? isComplete,
    bool? isRepeating,
    String? type,
    String? assignedTo,
    String? sourceId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dueDate: dueDate ?? this.dueDate,
      isComplete: isComplete ?? this.isComplete,
      isRepeating: isRepeating ?? this.isRepeating,
      type: type ?? this.type,
      assignedTo: assignedTo ?? this.assignedTo,
      sourceId: sourceId ?? this.sourceId,
    );
  }

  // Factory constructor to create a TaskModel from a Firestore document
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      name: data['name'] ?? '',
      dueDate: data['dueDate'] ?? Timestamp.now(),
      isComplete: data['isComplete'] ?? false,
      isRepeating: data['isRepeating'] ?? false,
      type: data['type'] ?? 'Task',
      assignedTo: data['assignedTo'],
      sourceId: data['sourceId'],
    );
  }

  // Method to convert a TaskModel to a Map for writing to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'dueDate': dueDate,
      'isComplete': isComplete,
      'isRepeating': isRepeating,
      'type': type,
      'assignedTo': assignedTo,
      'sourceId': sourceId,
    };
  }
}
