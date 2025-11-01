import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/providers/firestore_providers.dart';
import 'package:homely/features/auth/providers/auth_providers.dart';
import 'package:homely/features/finance/data/expense_service.dart';
import 'package:homely/features/finance/models/expense_model.dart';
import 'package:homely/features/household/providers/household_providers.dart';

// Provider for the ExpenseService
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService(ref.watch(firestoreProvider));
});

// This provider streams the list of expenses for the *current user's household*
final expenseListProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final expenseService = ref.watch(expenseServiceProvider);
  // --- FIX: Watch the currentUserModelProvider directly ---
  final userModel = ref.watch(currentUserModelProvider);
  final householdId = userModel?.householdId;
  // --- END FIX ---

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

  // --- FIX: Get householdId and userId directly ---
  String? get _householdId => _ref.read(currentUserModelProvider)?.householdId;
  String? get _userId => _ref.read(authStateProvider).value?.uid;
  // --- END FIX ---

  Future<void> addExpense(ExpenseModel expense) async {
    state = true;
    try {
      if (_householdId == null || _userId == null) {
        throw Exception('User is not associated with a household.');
      }
      // Ensure the 'addedBy' field is set
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

// This provider calculates the total spending for the current month
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
