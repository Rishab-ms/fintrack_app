# Introduction to Testing in FinTrack App

Welcome to the testing guide for the FinTrack application! If you've never written a test before, don't worry – this document will introduce you to the basics of software testing and guide you through the existing test suite in this project.

## What is Software Testing and Why is it Important?

Software testing is the process of evaluating a software application to ensure that it meets specified requirements and functions as expected. It's a crucial part of the development lifecycle for several reasons:

*   **Ensures Correctness**: Tests verify that your code behaves as intended, catching bugs and errors early.
*   **Improves Reliability**: A well-tested application is more stable and less prone to unexpected crashes.
*   **Facilitates Refactoring**: With a robust test suite, you can confidently refactor and improve your code without fear of introducing regressions.
*   **Documents Code Behavior**: Tests serve as living documentation, illustrating how different parts of the application are supposed to work.

## Project Test Structure

The tests in the FinTrack app are organized within the `test/` directory, mirroring the main application's `lib/` structure. This organization helps in easily locating tests related to specific parts of the application:

*   **`test/core/`**: Contains tests for core functionalities, such as data models, repositories, and services that are fundamental to the application's operation.
    *   Example: `test/core/data/repositories/transaction_repository_test.dart`
*   **`test/features/`**: Houses tests for individual features of the application, including presentation layer components like widgets and screens.
    *   Example: `test/features/transactions/presentation/widgets/add_transaction_modal_test.dart`

## Types of Tests

In this project, you'll primarily encounter two types of tests:

### 1. Unit Tests

Unit tests focus on testing individual, isolated units of code (e.g., a single function, method, or class) to ensure they work correctly in isolation.

*   **Characteristics**:
    *   They are fast to run.
    *   They test small pieces of logic.
    *   Dependencies are often "mocked" or faked to ensure the unit under test is truly isolated.
*   **Example (from `transaction_repository_test.dart`)**:
    ```dart
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
    ```
    In this example, `mockTransactionBox` is a mock object created using the `mocktail` package. This allows us to test `TransactionRepository` without actually interacting with a real Hive box, ensuring that only the repository's logic is being tested.

### 2. Widget Tests

Widget tests are used to verify the UI components (widgets) of the application. They ensure that widgets render correctly, respond to user interactions, and display the expected information.

*   **Characteristics**:
    *   They simulate user interactions (taps, text input).
    *   They check the visual output and state changes of widgets.
    *   They run in a test environment, not on a real device or emulator.
*   **Example (from `add_transaction_modal_test.dart`)**:
    ```dart
    testWidgets('displays income/expense toggle and amount input', (
      tester,
    ) async {
      await pumpAddTransactionModal(tester);

      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.byKey(const Key('amount_text_field')), findsOneWidget);
    });
    ```
    Here, `tester.pumpWidget` renders the `AddTransactionModal`, and `expect(find.text('Expense'), findsOneWidget)` verifies that the 'Expense' text is present on the screen. `tester.tap` and `tester.enterText` are used to simulate user interactions.

## How to Run Tests

You can run tests using the Flutter CLI:

*   **Run all tests**:
    ```bash
    flutter test
    ```
*   **Run tests in a specific file**:
    ```bash
    flutter test test/core/data/repositories/transaction_repository_test.dart
    ```
*   **Run a specific test within a file (by name)**:
    ```bash
    flutter test test/core/data/repositories/transaction_repository_test.dart --name "addTransaction adds a transaction to the box"
    ```

## Key Testing Concepts

You'll frequently encounter these concepts in the existing tests:

*   **`group('Description', () { ... });`**: Used to group related tests together.
*   **`test('Description', () async { ... });`**: Defines an individual test case.
*   **`setUp(() { ... });`**: A function that runs before each test (or before all tests in a `setUpAll` block) within its scope. Useful for initializing common variables or mocks.
*   **`tearDown(() { ... });`**: A function that runs after each test (or after all tests in a `tearDownAll` block) within its scope. Useful for cleaning up resources.
*   **`expect(actual, matcher);`**: The core assertion function. It checks if `actual` matches the `matcher`.
*   **`verify(() => mockObject.method(any())).called(1);`**: Used with `mocktail` to verify that a mocked method was called a certain number of times with specific arguments.
*   **`tester.pumpWidget(widget);`**: Renders a widget in the test environment for widget tests.
*   **`tester.pumpAndSettle();`**: Waits for all animations and microtasks to complete, ensuring the UI is stable before making assertions in widget tests.

Happy testing!
