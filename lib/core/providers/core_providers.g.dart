// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hiveServiceHash() => r'be81bf6915eb03b2beee510fecdb75df7f4780ad';

/// See also [hiveService].
@ProviderFor(hiveService)
final hiveServiceProvider = FutureProvider<HiveService>.internal(
  hiveService,
  name: r'hiveServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hiveServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HiveServiceRef = FutureProviderRef<HiveService>;
String _$transactionRepositoryHash() =>
    r'0154c9395ae5fdd1bd45aa8399371dbe2c19453a';

/// See also [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider =
    FutureProvider<TransactionRepository>.internal(
  transactionRepository,
  name: r'transactionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TransactionRepositoryRef = FutureProviderRef<TransactionRepository>;
String _$budgetRepositoryHash() => r'1e3ca1edba1df3a3fc315597e739c3c786b2de7a';

/// See also [budgetRepository].
@ProviderFor(budgetRepository)
final budgetRepositoryProvider = FutureProvider<BudgetRepository>.internal(
  budgetRepository,
  name: r'budgetRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BudgetRepositoryRef = FutureProviderRef<BudgetRepository>;
String _$allTransactionsHash() => r'29225687d6c89f0e04bf183dc2f2d7174ddf55a4';

/// See also [allTransactions].
@ProviderFor(allTransactions)
final allTransactionsProvider = StreamProvider<List<Transaction>>.internal(
  allTransactions,
  name: r'allTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllTransactionsRef = StreamProviderRef<List<Transaction>>;
String _$allBudgetsHash() => r'1b9d5c92d33855ed59b42bd5890cd634249558e4';

/// See also [allBudgets].
@ProviderFor(allBudgets)
final allBudgetsProvider = StreamProvider<List<Budget>>.internal(
  allBudgets,
  name: r'allBudgetsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allBudgetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllBudgetsRef = StreamProviderRef<List<Budget>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
