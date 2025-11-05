import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/data/repositories/transaction_repository.dart';
import 'package:fintrack_app/core/shared/constants.dart';

// Mock Hive Box
class MockTransactionBox extends Mock implements Box<Transaction> {}

void main() {
  group('TransactionRepository', () {
    late TransactionRepository transactionRepository;
    late MockTransactionBox mockTransactionBox;

    setUpAll(() {
      registerFallbackValue(
        Transaction(
          id: 'test',
          amount: 0.0,
          date: DateTime.now(),
          type: TransactionType.income,
          description: '',
          category: null,
        ),
      );
    });

    setUp(() {
      mockTransactionBox = MockTransactionBox();
      transactionRepository = TransactionRepository(mockTransactionBox);
      // Provide a default empty list for .values to prevent Null errors
      when(() => mockTransactionBox.values).thenReturn([]);
    });

    test('addTransaction adds a transaction to the box', () async {
      final transaction = Transaction(
        id: '1',
        amount: 100.0,
        date: DateTime.now(),
        type: TransactionType.income,
        description: 'Salary',
        category: null,
      );

      when(
        () => mockTransactionBox.put(transaction.id, transaction),
      ).thenAnswer((_) async {});

      await transactionRepository.addTransaction(transaction);

      verify(
        () => mockTransactionBox.put(transaction.id, transaction),
      ).called(1);
    });

    test('deleteTransaction deletes a transaction from the box', () async {
      const transactionId = '1';

      when(
        () => mockTransactionBox.delete(transactionId),
      ).thenAnswer((_) async {});

      await transactionRepository.deleteTransaction(transactionId);

      verify(() => mockTransactionBox.delete(transactionId)).called(1);
    });

    test(
      'updateTransaction updates an existing transaction in the box',
      () async {
        final updatedTransaction = Transaction(
          id: '1',
          amount: 120.0,
          date: DateTime.now(),
          type: TransactionType.income,
          description: 'Bonus',
          category: null,
        );

        when(
          () =>
              mockTransactionBox.put(updatedTransaction.id, updatedTransaction),
        ).thenAnswer((_) async {});

        await transactionRepository.updateTransaction(updatedTransaction);

        verify(
          () =>
              mockTransactionBox.put(updatedTransaction.id, updatedTransaction),
        ).called(1);
      },
    );

    test(
      'watchAllTransactions emits transactions when the box changes (using emitsInOrder)',
      () async {
        final transaction1 = Transaction(
          id: '1',
          amount: 50.0,
          date: DateTime.now(),
          type: TransactionType.expense,
          description: 'Groceries',
          category: Category.food,
        );
        final transaction2 = Transaction(
          id: '2',
          amount: 20.0,
          date: DateTime.now(),
          type: TransactionType.expense,
          description: 'Coffee',
          category: Category.food,
        );

        final List<Transaction> currentTransactions = [transaction1];

        final controller = StreamController<BoxEvent>();
        when(() => mockTransactionBox.watch()).thenAnswer((_) => controller.stream);
        when(() => mockTransactionBox.values.toList()).thenAnswer((_) => currentTransactions.toList());

        // Use expectLater to assert the stream's emissions over time
        expectLater(
          transactionRepository.watchAllTransactions(),
          emitsInOrder([
            [transaction1], // Initial emission
            [transaction1, transaction2], // Emission after adding transaction2
          ]),
        );

        // Allow the initial emission to occur
        await pumpEventQueue();

        // Simulate adding transaction2
        currentTransactions.add(transaction2);
        controller.add(BoxEvent('2', transaction2, false));

        // Allow the event loop to process the stream event and the next emission
        await pumpEventQueue();
      },
    );
  });
}
