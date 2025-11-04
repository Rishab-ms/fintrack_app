// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hiveServiceHash() => r'736c4ce10a0f18e71445b2cae3c365a50f24d1d0';

/// See also [hiveService].
@ProviderFor(hiveService)
final hiveServiceProvider = Provider<HiveService>.internal(
  hiveService,
  name: r'hiveServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hiveServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HiveServiceRef = ProviderRef<HiveService>;
String _$transactionRepositoryHash() =>
    r'7aa8080539893176a4f3b8e28843f2e603717dc6';

/// See also [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider = Provider<TransactionRepository>.internal(
  transactionRepository,
  name: r'transactionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TransactionRepositoryRef = ProviderRef<TransactionRepository>;
String _$budgetRepositoryHash() => r'a535dc7cdbb93a6fbdc6bae7fa2970b6804042ef';

/// See also [budgetRepository].
@ProviderFor(budgetRepository)
final budgetRepositoryProvider = Provider<BudgetRepository>.internal(
  budgetRepository,
  name: r'budgetRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BudgetRepositoryRef = ProviderRef<BudgetRepository>;
String _$allTransactionsHash() => r'a1404f820b0601584e4b7a79cec6b77b5f91eca2';

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
String _$allBudgetsHash() => r'f48a9cefb935e96bb3c7f92f73c950a12529e9af';

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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, inference_failure_on_uninitialized_variable, inference_failure_on_function_return_type, inference_failure_on_untyped_parameter, deprecated_member_use_from_same_package
