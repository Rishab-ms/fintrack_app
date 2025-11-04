import 'package:fintrack_app/core/shared/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fintrack_app/core/data/models/budget_model.dart';

/// A repository for managing [Budget] data using Hive for local persistence.
///
/// This class provides CRUD (Create, Read, Update, Delete) operations
/// for budgets and exposes a stream to react to changes in the budget data.
class BudgetRepository {
  final Box<Budget> _budgetBox;

  /// Constructs a [BudgetRepository] with the given Hive box for budgets.
  BudgetRepository(this._budgetBox);

  /// Returns a stream of all budgets, reacting to changes in the Hive box.
  ///
  /// This method uses an `async*` generator to create a stream.
  /// 1. It `yield`s the current list of budgets immediately upon subscription.
  ///    This ensures that consumers of the stream (e.g., Riverpod providers, UI widgets)
  ///    receive an initial value right away, preventing them from being stuck in a loading state
  ///    even if the box is empty.
  /// 2. It then `await for` changes in the `_budgetBox.watch()` stream.
  ///    `_budgetBox.watch()` emits a [BoxEvent] whenever data in the box changes.
  ///    For each change, it `yield`s the updated list of all budgets.
  ///    The `_` is used for the `event` variable because the specific event details
  ///    are not needed; only the fact that a change occurred is relevant to re-emit the list.
  Stream<List<Budget>> watchAllBudgets() async* {
    yield _budgetBox.values.toList(); // Emit current list immediately
    await for (final _ in _budgetBox.watch()) { // Use '_' to ignore the unused 'event' variable
      yield _budgetBox.values.toList();
    }
  }

  /// Saves a budget. If a budget for the category already exists, it updates it;
  /// otherwise, it adds a new budget.
  ///
  /// Hive does not provide a direct "update by key" mechanism for objects
  /// where the key is not the object itself (like [Category] in this case).
  /// Therefore, this method first attempts to find an existing budget for the
  /// given [category].
  /// - If an existing budget is found and its content is different from the new [budget],
  ///   the old budget is deleted, and the new one is added. This effectively updates it.
  /// - If no existing budget is found (or `orElse` returns the new budget itself),
  ///   the new budget is simply added to the box.
  Future<void> saveBudget(Budget budget) async {
    // Use the category name as the key for the budget
    await _budgetBox.put(budget.category.name, budget);
  }

  /// Deletes a budget by its [Category].
  ///
  /// It removes the budget associated with the given [category] from the Hive box.
  /// If no budget is found for the specified category, the operation will complete
  /// without error, as Hive's delete method is idempotent.
  Future<void> deleteBudget(Category category) async {
    await _budgetBox.delete(category.name);
  }
}
