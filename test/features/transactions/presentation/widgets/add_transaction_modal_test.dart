import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/data/repositories/transaction_repository.dart';
import 'package:fintrack_app/core/providers/core_providers.dart';
import 'package:fintrack_app/core/shared/constants.dart';
import 'package:fintrack_app/features/transactions/presentation/widgets/add_transaction_modal.dart';

// Mock TransactionRepository
class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  group('AddTransactionModal', () {
    late MockTransactionRepository mockTransactionRepository;
    late ProviderContainer container;

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
      mockTransactionRepository = MockTransactionRepository();
      container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWith(
            (ref) async => mockTransactionRepository,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    Future<void> pumpAddTransactionModal(WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: AddTransactionModal())),
        ),
      );
    }

    testWidgets('displays income/expense toggle and amount input', (
      tester,
    ) async {
      await pumpAddTransactionModal(tester);

      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.byKey(const Key('amount_text_field')), findsOneWidget);
    });

    testWidgets('shows category selection for expense and hides for income', (
      tester,
    ) async {
      await pumpAddTransactionModal(tester);

      // Initially Expense is selected, categories should be visible
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Travel'), findsOneWidget);

      // Tap on Income
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      // Categories should be hidden
      expect(find.text('Food'), findsNothing);
      expect(find.text('Travel'), findsNothing);

      // Tap back to Expense
      await tester.tap(find.text('Expense'));
      await tester.pumpAndSettle();

      // Categories should be visible again
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Travel'), findsOneWidget);
    });

    testWidgets('validates amount input', (tester) async {
      await pumpAddTransactionModal(tester);

      // Try to add transaction with empty amount
      await tester.tap(find.text('Add Transaction'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid Input'), findsOneWidget);
      expect(
        find.text('Please make sure a valid amount was entered.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Okay'));
      await tester.pumpAndSettle();

      // Try to add transaction with zero amount
      await tester.enterText(find.byKey(const Key('amount_text_field')), '0');
      await tester.tap(find.text('Add Transaction'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid Input'), findsOneWidget);
      expect(
        find.text('Please make sure a valid amount was entered.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Okay'));
      await tester.pumpAndSettle();
    });

    testWidgets('adds an expense transaction successfully', (tester) async {
      when(
        () => mockTransactionRepository.addTransaction(any()),
      ).thenAnswer((_) async {});

      await pumpAddTransactionModal(tester);

      // Enter valid amount and description
      await tester.enterText(
        find.byKey(const Key('amount_text_field')),
        '123.45',
      );
      await tester.enterText(
        find.byKey(const Key('description_text_field')),
        'Test Expense',
      );

      // Select a category
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Tap add transaction
      await tester.tap(find.text('Add Transaction'));
      await tester.pumpAndSettle();

      // Verify addTransaction was called with correct data
      verify(
        () => mockTransactionRepository.addTransaction(
          any(
            that: isA<Transaction>()
                .having((t) => t.amount, 'amount', 123.45)
                .having((t) => t.type, 'type', TransactionType.expense)
                .having((t) => t.description, 'description', 'Test Expense')
                .having((t) => t.category, 'category', Category.food),
          ),
        ),
      ).called(1);
    });

    testWidgets('adds an income transaction successfully', (tester) async {
      when(
        () => mockTransactionRepository.addTransaction(any()),
      ).thenAnswer((_) async {});

      await pumpAddTransactionModal(tester);

      // Switch to Income
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      // Enter valid amount and description
      await tester.enterText(
        find.byKey(const Key('amount_text_field')),
        '500.00',
      );
      await tester.enterText(
        find.byKey(const Key('description_text_field')),
        'Test Income',
      );

      // Tap add transaction
      await tester.tap(find.text('Add Transaction'));
      await tester.pumpAndSettle();

      // Verify addTransaction was called with correct data
      verify(
        () => mockTransactionRepository.addTransaction(
          any(
            that: isA<Transaction>()
                .having((t) => t.amount, 'amount', 500.00)
                .having((t) => t.type, 'type', TransactionType.income)
                .having((t) => t.description, 'description', 'Test Income')
                .having((t) => t.category, 'category', null),
          ),
        ),
      ).called(1);
    });
  });
}
