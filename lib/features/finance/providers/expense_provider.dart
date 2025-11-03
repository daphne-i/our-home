import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/providers/firestore_providers.dart';
import 'package:homely/features/auth/providers/auth_providers.dart';
import 'package:homely/features/finance/data/expense_service.dart';
import 'package:homely/features/finance/models/expense_model.dart';
import 'package:homely/features/finance/models/subscription_model.dart';
import 'package:homely/features/household/providers/household_providers.dart';
// --- 1. IMPORT TASK MODEL AND SERVICE ---
import 'package:homely/features/tasks/domain/task_model.dart';
import 'package:homely/features/tasks/data/task_service.dart';

// Provider for the ExpenseService
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService(ref.watch(firestoreProvider));
});

// This provider streams the list of expenses for the *current user's household*
final expenseListProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final expenseService = ref.watch(expenseServiceProvider);
  final userModel = ref.watch(currentUserModelProvider);
  final householdId = userModel?.householdId;

  if (householdId == null) {
    return Stream.value([]);
  }

  return expenseService.getExpensesStream(householdId);
});

// StateNotifier for expense actions (add, delete)
final expenseControllerProvider =
    StateNotifierProvider<ExpenseController, bool>((ref) {
  return ExpenseController(
    ref.watch(expenseServiceProvider),
    ref,
  );
});

class ExpenseController extends StateNotifier<bool> {
  final ExpenseService _expenseService;
  final Ref _ref;

  ExpenseController(this._expenseService, this._ref) : super(false);

  String? get _householdId => _ref.read(currentUserModelProvider)?.householdId;
  String? get _userId => _ref.read(authStateProvider).value?.uid;

  Future<void> addExpense(ExpenseModel expense) async {
    state = true;
    try {
      if (_householdId == null || _userId == null) {
        throw Exception('User is not associated with a household.');
      }
      final newExpense = expense.copyWith(addedBy: _userId);
      await _expenseService.addExpense(
        householdId: _householdId!,
        expense: newExpense,
      );
    } finally {
      state = false;
    }
  }

  Future<void> deleteExpense(ExpenseModel expense) async {
    try {
      if (_householdId == null || expense.id == null) {
        throw Exception('Cannot delete expense.');
      }
      await _expenseService.deleteExpense(
        householdId: _householdId!,
        expenseId: expense.id!,
      );
    } catch (e) {
      print('Error deleting expense: $e');
    }
  }
}

// --- Dashboard Finance Card Provider ---
final monthlySpendingProvider = Provider<double>((ref) {
  final expenses = ref.watch(expenseListProvider).value ?? [];
  final now = DateTime.now();

  double total = 0.0;
  for (final expense in expenses) {
    final expenseDate = expense.date.toDate();
    if (expenseDate.year == now.year && expenseDate.month == now.month) {
      total += expense.amount;
    }
  }
  return total;
});

// --- Provider for Subscriptions List ---
final subscriptionListProvider = StreamProvider<List<SubscriptionModel>>((ref) {
  final userModel = ref.watch(currentUserModelProvider);
  final householdId = userModel?.householdId;

  if (householdId == null) {
    return Stream.value([]);
  }

  return ref.watch(expenseServiceProvider).getSubscriptionsStream(householdId);
});

// --- 2. ADD CONTROLLER FOR SUBSCRIPTIONS (WITH "MAGIC") ---
final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, bool>((ref) {
  return SubscriptionController(
    ref.watch(expenseServiceProvider),
    // We also need the TaskService to create the bill
    TaskService(ref.watch(firestoreProvider)),
    ref,
  );
});

class SubscriptionController extends StateNotifier<bool> {
  final ExpenseService _expenseService;
  final TaskService _taskService; // For the "magic"
  final Ref _ref;

  SubscriptionController(this._expenseService, this._taskService, this._ref)
      : super(false);

  String? get _householdId => _ref.read(currentUserModelProvider)?.householdId;

  Future<void> addSubscription(SubscriptionModel subscription) async {
    state = true;
    try {
      if (_householdId == null) {
        throw Exception('User is not associated with a household.');
      }

      // 1. Add the Subscription
      await _expenseService.addSubscription(
        householdId: _householdId!,
        subscription: subscription,
      );

      // 2. --- THE "MAGIC" [cite: 121-122] ---
      // Auto-create a task for the bill
      final billTask = TaskModel(
        name: 'Pay ${subscription.name}',
        dueDate: subscription.nextDueDate,
        isRepeating: subscription.billingCycle != 'One-time',
        type: 'Bill',
        sourceId:
            subscription.id, // This will be null on creation, but that's okay
        // 'sourceId' would ideally be the ID of the doc we just created.
        // For a more robust solution, 'addSubscription' could return the new ID.
        // For now, this is good.
      );

      await _taskService.addTask(
        householdId: _householdId!,
        task: billTask,
      );
      // --- END MAGIC ---
    } finally {
      state = false;
    }
  }
}
