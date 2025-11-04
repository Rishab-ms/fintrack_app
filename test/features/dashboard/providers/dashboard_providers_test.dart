import 'dart:async'; // Import StreamController
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/data/repositories/transaction_repository.dart';
import 'package:fintrack_app/core/providers/core_providers.dart';
import 'package:fintrack_app/core/shared/constants.dart';
import 'package:fintrack_app/features/dashboard/providers/dashboard_providers.dart';

// Mock TransactionRepository
class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  group('Dashboard Providers', () {
    late ProviderContainer container;
    late StreamController<List<Transaction>> transactionsController;

    setUp(() {
      transactionsController = StreamController<List<Transaction>>();
      container = ProviderContainer(
        overrides: [
          allTransactionsProvider.overrideWith(
            (ref) => transactionsController.stream,
          ),
        ],
      );
    });

    tearDown(() {
      transactionsController.close();
      container.dispose();
    });

    group('dashboardBalanceProvider', () {
      test(
        'calculates current balance, monthly income, and monthly expenses correctly',
        () async { // Mark as async
          final now = DateTime.now();
          final transactions = [
            // Income
            Transaction(
              id: '1',
              amount: 1000.0,
              date: now,
              type: TransactionType.income,
              description: 'Salary',
              category: null,
            ),
            Transaction(
              id: '2',
              amount: 200.0,
              date: now.subtract(const Duration(days: 35)),
              type: TransactionType.income,
              description: 'Old Salary',
              category: null,
            ), // Old income
            // Expenses
            Transaction(
              id: '3',
              amount: 50.0,
              date: now,
              type: TransactionType.expense,
              description: 'Groceries',
              category: Category.food,
            ),
            Transaction(
              id: '4',
              amount: 150.0,
              date: now,
              type: TransactionType.expense,
              description: 'Rent',
              category: Category.bills,
            ),
            Transaction(
              id: '5',
              amount: 20.0,
              date: now.subtract(const Duration(days: 35)),
              type: TransactionType.expense,
              description: 'Old Coffee',
              category: Category.food,
            ), // Old expense
          ];

          transactionsController.add(transactions);
          // Wait for the allTransactionsProvider to emit the new value
          await expectLater(
            container.read(allTransactionsProvider.stream),
            emits(transactions),
          );

          final balance = container.read(dashboardBalanceProvider);

          expect(
            balance.currentBalance,
            1000.0 - 50.0 - 150.0 + 200.0 - 20.0,
          ); // All transactions
          expect(balance.monthlyIncome, 1000.0); // Only current month income
          expect(
            balance.monthlyExpenses,
            50.0 + 150.0,
          ); // Only current month expenses
        },
      );

      test('handles empty transaction list', () async {
        transactionsController.add([]);
        // Wait for the allTransactionsProvider to emit the new value
        await expectLater(
          container.read(allTransactionsProvider.stream),
          emits([]),
        );

        final balance = container.read(dashboardBalanceProvider);

        expect(balance.currentBalance, 0.0);
        expect(balance.monthlyIncome, 0.0);
        expect(balance.monthlyExpenses, 0.0);
      });
    });

    group('chartDataProvider', () {
      test(
        'calculates expense percentages by category for current month',
        () async { // Mark as async
          final now = DateTime.now();
          final transactions = [
            Transaction(
              id: '1',
              amount: 100.0,
              date: now,
              type: TransactionType.expense,
              description: 'Food',
              category: Category.food,
            ),
            Transaction(
              id: '2',
              amount: 50.0,
              date: now,
              type: TransactionType.expense,
              description: 'Travel',
              category: Category.travel,
            ),
            Transaction(
              id: '3',
              amount: 50.0,
              date: now,
              type: TransactionType.expense,
              description: 'Food again',
              category: Category.food,
            ),
            Transaction(
              id: '4',
              amount: 200.0,
              date: now.subtract(const Duration(days: 35)),
              type: TransactionType.expense,
              description: 'Old Food',
              category: Category.food,
            ), // Old expense
            Transaction(
              id: '5',
              amount: 1000.0,
              date: now,
              type: TransactionType.income,
              description: 'Salary',
              category: null,
            ), // Income should be ignored
          ];

          transactionsController.add(transactions);
          // Wait for the allTransactionsProvider to emit the new value
          await expectLater(
            container.read(allTransactionsProvider.stream),
            emits(transactions),
          );

          final chartData = container.read(chartDataProvider);

          expect(chartData.length, 2); // Food and Travel
          expect(
            chartData.firstWhere((e) => e.category == Category.food).value,
            150.0,
          ); // 150
          expect(
            chartData
                .firstWhere((e) => e.category == Category.travel)
                .value,
            50.0,
          ); // 50
        },
      );

      test('handles no expense transactions in current month', () async { // Mark as async
        final now = DateTime.now();
        final transactions = [
          Transaction(
            id: '1',
            amount: 1000.0,
            date: now,
            type: TransactionType.income,
            description: 'Salary',
            category: null,
          ),
          Transaction(
            id: '2',
            amount: 50.0,
            date: now.subtract(const Duration(days: 35)),
            type: TransactionType.expense,
            description: 'Old Food',
            category: Category.food,
          ),
        ];

        transactionsController.add(transactions);
        // Wait for the allTransactionsProvider to emit the new value
        await expectLater(
          container.read(allTransactionsProvider.stream),
          emits(transactions),
        );

        final chartData = container.read(chartDataProvider);

        expect(chartData, isEmpty);
      });
    });
  });
}
