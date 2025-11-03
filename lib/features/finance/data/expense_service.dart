import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homely/features/finance/models/expense_model.dart';
// --- 1. IMPORT THE NEW MODEL ---
import 'package:homely/features/finance/models/subscription_model.dart';

// This service handles all Firestore operations for expenses.
class ExpenseService {
  final FirebaseFirestore _firestore;

  ExpenseService(this._firestore);

  // --- METHODS FOR EXPENSES (Existing) ---

  // Get a stream of all expenses for a household
  Stream<List<ExpenseModel>> getExpensesStream(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    });
  }

  // Add a new expense
  Future<void> addExpense({
    required String householdId,
    required ExpenseModel expense,
  }) async {
    try {
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('expenses')
          .add(expense.toFirestore());
    } catch (e) {
      // Re-throw to be caught by the UI
      rethrow;
    }
  }

  // Delete an expense
  Future<void> deleteExpense({
    required String householdId,
    required String expenseId,
  }) async {
    try {
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('expenses')
          .doc(expenseId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // --- 2. ADD METHODS FOR SUBSCRIPTIONS ---

  // Get a stream of all subscriptions for a household
  Stream<List<SubscriptionModel>> getSubscriptionsStream(String householdId) {
    return _firestore
        .collection('households')
        .doc(householdId)
        .collection('subscriptions')
        .orderBy('nextDueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromFirestore(doc))
          .toList();
    });
  }

  // Add a new subscription
  Future<void> addSubscription({
    required String householdId,
    required SubscriptionModel subscription,
  }) async {
    try {
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('subscriptions')
          .add(subscription.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  // TODO: Add updateSubscription and deleteSubscription methods later
}
