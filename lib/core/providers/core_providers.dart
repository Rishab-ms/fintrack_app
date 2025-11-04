import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fintrack_app/core/data/repositories/transaction_repository.dart';
import 'package:fintrack_app/core/data/repositories/budget_repository.dart';
import 'package:fintrack_app/core/data/services/hive_service.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/data/models/budget_model.dart';

part 'core_providers.g.dart';

@Riverpod(keepAlive: true)
HiveService hiveService(HiveServiceRef ref) {
  return HiveService();
}

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  return TransactionRepository(ref.watch(hiveServiceProvider));
}

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(BudgetRepositoryRef ref) {
  return BudgetRepository(ref.watch(hiveServiceProvider));
}

@Riverpod(keepAlive: true)
Stream<List<Transaction>> allTransactions(AllTransactionsRef ref) {
  return ref.watch(transactionRepositoryProvider).watchAllTransactions();
}

@Riverpod(keepAlive: true)
Stream<List<Budget>> allBudgets(AllBudgetsRef ref) {
  return ref.watch(budgetRepositoryProvider).watchAllBudgets();
}
