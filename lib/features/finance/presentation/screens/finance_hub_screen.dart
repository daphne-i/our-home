import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/features/finance/providers/expense_provider.dart';
import 'package:intl/intl.dart';
// --- 1. IMPORT THE NEW MODAL ---
import 'package:homely/features/finance/presentation/screens/add_subscription_modal.dart';

class FinanceHubScreen extends ConsumerStatefulWidget {
  const FinanceHubScreen({super.key});

  @override
  ConsumerState<FinanceHubScreen> createState() => _FinanceHubScreenState();
}

class _FinanceHubScreenState extends ConsumerState<FinanceHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Hub'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Transactions'),
            Tab(text: 'Subscriptions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TransactionsList(),
          _SubscriptionsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // --- 2. SHOW THE MODAL ---
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent, // Let modal style itself
            builder: (context) => const AddSubscriptionModal(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- (Rest of the file: _TransactionsList and _SubscriptionsList widgets) ---
// (No changes needed to the list widgets below)
class _TransactionsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseListProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (expenses) {
        if (expenses.isEmpty) {
          return const Center(child: Text('No transactions added yet.'));
        }
        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return ListTile(
              title: Text(expense.notes ?? 'No description'),
              subtitle: Text(expense.category),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(expense.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(DateFormat.yMMMd().format(expense.date.toDate())),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SubscriptionsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionListProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return subscriptionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (subscriptions) {
        if (subscriptions.isEmpty) {
          return const Center(child: Text('No subscriptions added yet.'));
        }
        return ListView.builder(
          itemCount: subscriptions.length,
          itemBuilder: (context, index) {
            final sub = subscriptions[index];
            return ListTile(
              title: Text(sub.name),
              subtitle: Text(
                  'Due ${DateFormat.yMMMd().format(sub.nextDueDate.toDate())}'),
              trailing: Text(
                '${currencyFormat.format(sub.amount)} / ${sub.billingCycle}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        );
      },
    );
  }
}
