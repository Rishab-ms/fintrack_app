import 'package:hive_flutter/hive_flutter.dart';
import 'package:fintrack_app/core/data/models/budget_model.dart';
import 'package:fintrack_app/core/data/services/hive_service.dart';

class BudgetRepository {
  final HiveService _hiveService;

  BudgetRepository(this._hiveService);

  Box<Budget> get _budgetBox => _hiveService.budgetBox;

  /// Returns a stream of all budgets, reacting to changes in the Hive box.
  Stream<List<Budget>> watchAllBudgets() {
    return _budgetBox.watch().map((event) => _budgetBox.values.toList());
  }
}
