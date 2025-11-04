import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fintrack_app/core/data/repositories/transaction_repository.dart';
import 'package:fintrack_app/core/data/repositories/budget_repository.dart';
import 'package:fintrack_app/core/data/services/hive_service.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/data/models/budget_model.dart';

part 'core_providers.g.dart';

@Riverpod(keepAlive: true)
Future<HiveService> hiveService(HiveServiceRef ref) async {
  final hiveService = HiveService();
  await hiveService.openBoxes();
  return hiveService;
}

@Riverpod(keepAlive: true)
Future<TransactionRepository> transactionRepository(
  TransactionRepositoryRef ref,
) async {
  final hiveService = await ref.watch(hiveServiceProvider.future);
  return TransactionRepository(hiveService.transactionBox);
}

@Riverpod(keepAlive: true)
Future<BudgetRepository> budgetRepository(BudgetRepositoryRef ref) async {
  final hiveService = await ref.watch(hiveServiceProvider.future);
  return BudgetRepository(hiveService.budgetBox);
}

@Riverpod(keepAlive: true)
Stream<List<Transaction>> allTransactions(AllTransactionsRef ref) async* {
  final transactionRepository = await ref.watch(
    transactionRepositoryProvider.future,
  );
  yield* transactionRepository.watchAllTransactions();
}

@Riverpod(keepAlive: true)
Stream<List<Budget>> allBudgets(AllBudgetsRef ref) async* {
  final budgetRepository = await ref.watch(budgetRepositoryProvider.future);
  yield* budgetRepository.watchAllBudgets();
}
