import 'package:cloud_firestore/cloud_firestore.dart';

// This is the model for a single expense, based on your design doc.
// Path: /households/{householdId}/expenses/{expenseId}
class ExpenseModel {
  final String? id;
  final double amount;
  final String category;
  final String? notes;
  final Timestamp date;
  final String addedBy;

  ExpenseModel({
    this.id,
    required this.amount,
    required this.category,
    this.notes,
    required this.date,
    required this.addedBy,
  });

  // Factory constructor to create an ExpenseModel from a Firestore document
  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] as String,
      notes: data['notes'] as String?,
      date: data['date'] as Timestamp,
      addedBy: data['addedBy'] as String,
    );
  }

  // Method to convert an ExpenseModel to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'category': category,
      'notes': notes,
      'date': date,
      'addedBy': addedBy,
    };
  }

  // CopyWith method for easy updates
  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? category,
    String? notes,
    Timestamp? date,
    String? addedBy,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      addedBy: addedBy ?? this.addedBy,
    );
  }
}
