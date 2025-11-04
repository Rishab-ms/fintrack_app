import 'package:hive_flutter/hive_flutter.dart';
import 'package:fintrack_app/core/data/models/budget_model.dart';
import 'package:fintrack_app/core/data/services/hive_service.dart';

class BudgetRepository {
  final Box<Budget> _budgetBox;

  BudgetRepository(this._budgetBox);

  /// Returns a stream of all budgets, reacting to changes in the Hive box.
  Stream<List<Budget>> watchAllBudgets() {
    return _budgetBox.watch().map((event) => _budgetBox.values.toList());
  }
}
