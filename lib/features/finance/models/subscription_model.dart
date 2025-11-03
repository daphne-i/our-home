import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String? id;
  final String name;
  final double amount;
  final String billingCycle;
  final Timestamp nextDueDate;
  final String? autoTaskId;

  SubscriptionModel({
    this.id,
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.nextDueDate,
    this.autoTaskId,
  });

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      name: data['name'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      billingCycle: data['billingCycle'] ?? 'Monthly',
      nextDueDate: data['nextDueDate'] ?? Timestamp.now(),
      autoTaskId: data['autoTaskId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'billingCycle': billingCycle,
      'nextDueDate': nextDueDate,
      'autoTaskId': autoTaskId,
    };
  }

  SubscriptionModel copyWith({
    String? id,
    String? name,
    double? amount,
    String? billingCycle,
    Timestamp? nextDueDate,
    String? autoTaskId,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      billingCycle: billingCycle ?? this.billingCycle,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      autoTaskId: autoTaskId ?? this.autoTaskId,
    );
  }
}
