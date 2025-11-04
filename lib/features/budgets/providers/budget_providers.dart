import 'package:flutter_riverpod/flutter_riverpod.dart' show StateProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fintrack_app/core/data/models/budget_model.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart'; // Required for TransactionType
import 'package:fintrack_app/core/providers/core_providers.dart';
import 'package:fintrack_app/core/shared/constants.dart';

part 'budget_providers.g.dart';

/// A [StateProvider] that tracks which [Category] is currently being edited.
///
/// This provider holds the [Category] enum value of the budget that is
/// currently in an editable state. If its value is `null`, no budget is
/// being edited. This is crucial for implementing the "single-edit" feature,
/// ensuring that only one budget card can be edited at any given time.
/// When a user clicks "edit" on one budget, any other budget in edit mode
/// will automatically revert to display mode.
final editingBudgetCategoryProvider = StateProvider<Category?>((ref) => null);

/// Represents the calculated budget status for a single expense category.
///
/// This class encapsulates all the necessary information to display a budget
/// card, including the defined limit, the amount spent in the current month,
/// the percentage of the budget used, and the remaining amount.
class BudgetStatus {
  final Category category;
  final double limit;
  final double spent;
  final double percentageUsed;
  final double amountRemaining;

  BudgetStatus({
    required this.category,
    required this.limit,
    required this.spent,
    required this.percentageUsed,
    required this.amountRemaining,
  });
}

/// A [Riverpod] provider that delivers a stream of [BudgetStatus] for all expense categories.
///
/// This provider combines data from [allBudgetsProvider] (for defined limits)
/// and [allTransactionsProvider] (for current month's spending).
/// It returns an [AsyncValue] to gracefully handle loading, error, and data states.
///
/// **Why `AsyncValue<List<BudgetStatus>>` and not `Stream<List<BudgetStatus>>`?**
/// By returning `AsyncValue`, this provider can directly leverage Riverpod's
/// built-in mechanisms for handling asynchronous data, including loading indicators
/// and error propagation, which simplifies UI consumption. It watches the
/// `AsyncValue` states of its dependencies and propagates them.
///
/// **Calculation Logic:**
/// 1. It watches `allBudgetsProvider` and `allTransactionsProvider` to react
///    to any changes in budgets or transactions.
/// 2. It checks the `isLoading` and `hasError` states of its dependencies.
///    If any dependency is loading or has an error, `budgetStatusProvider`
///    will also return a corresponding `AsyncValue.loading()` or `AsyncValue.error()`.
///    This ensures the UI correctly reflects the data fetching status.
/// 3. Once both dependencies have successfully loaded data (even if the lists are empty),
///    it proceeds with the calculations.
/// 4. For each [Category] (from `Category.values`):
///    - It finds the defined budget limit. If no budget is set for a category,
///      a default limit of 0.0 is used.
///    - It calculates the total amount spent in the *current month* for that category
///      by filtering `TransactionType.expense` transactions.
///    - It then computes `percentageUsed` and `amountRemaining`.
/// 5. Finally, it returns an `AsyncValue.data()` containing a list of [BudgetStatus]
///    objects for all categories.
@Riverpod(keepAlive: true)
AsyncValue<List<BudgetStatus>> budgetStatus(BudgetStatusRef ref) {
  final allBudgetsAsync = ref.watch(allBudgetsProvider);
  final allTransactionsAsync = ref.watch(allTransactionsProvider);

  // If either dependency is loading or has an error, propagate that state.
  if (allBudgetsAsync.isLoading || allTransactionsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (allBudgetsAsync.hasError) {
    return AsyncValue.error(
      allBudgetsAsync.error!,
      allBudgetsAsync.stackTrace ?? StackTrace.current, // Provide a non-nullable StackTrace
    );
  }
  if (allTransactionsAsync.hasError) {
    return AsyncValue.error(
      allTransactionsAsync.error!,
      allTransactionsAsync.stackTrace ?? StackTrace.current, // Provide a non-nullable StackTrace
    );
  }

  // Both dependencies have data, so we can safely access their values.
  final budgets = allBudgetsAsync.value!;
  final transactions = allTransactionsAsync.value!;

  final now = DateTime.now();
  final currentMonthTransactions = transactions.where((t) {
    return t.type == TransactionType.expense &&
        t.date.year == now.year &&
        t.date.month == now.month;
  }).toList();

  final List<BudgetStatus> budgetStatuses = [];

  for (final category in Category.values) {
    final budget = budgets.firstWhere(
      (b) => b.category == category,
      orElse: () => Budget(category: category, limit: 0.0),
    );

    final spent = currentMonthTransactions
        .where((t) => t.category == category)
        .fold(0.0, (sum, t) => sum + t.amount);

    final limit = budget.limit;
    final percentageUsed = limit > 0 ? (spent / limit) : 0.0;
    final amountRemaining = limit - spent;

    budgetStatuses.add(
      BudgetStatus(
        category: category,
        limit: limit,
        spent: spent,
        percentageUsed: percentageUsed,
        amountRemaining: amountRemaining,
      ),
    );
  }
  return AsyncValue.data(budgetStatuses);
}
