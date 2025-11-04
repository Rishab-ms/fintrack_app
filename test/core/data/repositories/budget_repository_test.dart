import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fintrack_app/core/data/models/budget_model.dart';
import 'package:fintrack_app/core/data/repositories/budget_repository.dart';
import 'package:fintrack_app/core/shared/constants.dart';

// A fake in-memory implementation of Hive's Box for testing
class FakeBudgetBox implements Box<Budget> {
  final Map<dynamic, Budget> _data = {};
  final StreamController<BoxEvent> _controller = StreamController.broadcast();

  @override
  Iterable<Budget> get values => _data.values;

  @override
  Future<void> put(dynamic key, Budget value) async {
    _data[key] = value;
    _controller.add(BoxEvent(key, value, false)); // Simulate put event
  }

  @override
  Future<int> add(Budget value) async {
    // Simulate Hive's auto-incrementing key or use a unique identifier
    final key =
        value.category.name; // Using category name as key for simplicity
    _data[key] = value;
    _controller.add(BoxEvent(key, value, false)); // Simulate add event
    return _data.length - 1; // Return a dummy index
  }

  @override
  Future<void> delete(dynamic key) async {
    final value = _data.remove(key);
    if (value != null) {
      _controller.add(BoxEvent(key, value, true)); // Simulate delete event
    }
  }

  @override
  Stream<BoxEvent> watch({dynamic key}) {
    return _controller.stream;
  }

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    _controller.add(BoxEvent(null, null, false)); // Simulate clear event
    return count;
  }

  // Implement other Box methods as needed for the tests
  @override
  bool get isOpen => true;

  @override
  String get name => 'fakeBudgetBox';

  @override
  Future<void> close() async {
    await _controller.close();
  }

  @override
  Budget? get(dynamic key, {Budget? defaultValue}) {
    return _data[key] ?? defaultValue;
  }

  @override
  bool containsKey(dynamic key) {
    return _data.containsKey(key);
  }

  @override
  int get length => _data.length;

  @override
  Iterable<dynamic> get keys => _data.keys;

  @override
  Future<void> putAll(Map<dynamic, Budget> entries) async {
    entries.forEach((key, value) {
      _data[key] = value;
      _controller.add(BoxEvent(key, value, false));
    });
  }

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    keys.forEach((key) {
      final value = _data.remove(key);
      if (value != null) {
        _controller.add(BoxEvent(key, value, true));
      }
    });
  }

  @override
  Future<void> compact() => Future.value();

  @override
  Future<void> flush() => Future.value();

  @override
  String get path => '';

  @override
  Map<dynamic, Budget> toMap() => Map.from(_data);

  Budget? operator [](dynamic key) => get(key);

  void operator []=(dynamic key, Budget value) => put(key, value);

  @override
  Future<void> deleteFromDisk() => Future.value();

  @override
  Future<void> putAt(int index, Budget value) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAt(int index) {
    throw UnimplementedError();
  }

  @override
  Budget? getAt(int index) {
    throw UnimplementedError();
  }

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  dynamic keyAt(int index) {
    return _data.keys.elementAt(index);
  }

  @override
  Iterable<Budget> valuesBetween({dynamic startKey, dynamic endKey}) {
    throw UnimplementedError();
  }

  @override
  Future<Iterable<int>> addAll(Iterable<Budget> values) {
    throw UnimplementedError();
  }

  @override
  bool get lazy => false;
}

void main() {
  group('BudgetRepository', () {
    late BudgetRepository budgetRepository;
    late FakeBudgetBox fakeBudgetBox; // Use FakeBudgetBox

    setUpAll(() {});

    setUp(() {
      fakeBudgetBox = FakeBudgetBox(); // Initialize FakeBudgetBox
      budgetRepository = BudgetRepository(fakeBudgetBox);
    });

    test('saveBudget adds or updates a budget', () async {
      final budget1 = Budget(category: Category.food, limit: 500.0);
      await budgetRepository.saveBudget(budget1);
      expect(fakeBudgetBox.get(Category.food.name), budget1);
      expect(fakeBudgetBox.length, 1);

      final updatedBudget1 = Budget(category: Category.food, limit: 600.0);
      await budgetRepository.saveBudget(updatedBudget1);
      expect(fakeBudgetBox.get(Category.food.name), updatedBudget1);
      expect(fakeBudgetBox.length, 1); // Still 1, but updated

      final budget2 = Budget(category: Category.travel, limit: 200.0);
      await budgetRepository.saveBudget(budget2);
      expect(fakeBudgetBox.get(Category.travel.name), budget2);
      expect(fakeBudgetBox.length, 2);
    });

    test('deleteBudget deletes a budget by category', () async {
      final budget1 = Budget(category: Category.food, limit: 500.0);
      final budget2 = Budget(category: Category.travel, limit: 200.0);
      await fakeBudgetBox.put(budget1.category.name, budget1);
      await fakeBudgetBox.put(budget2.category.name, budget2);
      expect(fakeBudgetBox.length, 2);

      await budgetRepository.deleteBudget(Category.food);
      expect(fakeBudgetBox.containsKey(Category.food.name), isFalse);
      expect(fakeBudgetBox.length, 1);
      expect(fakeBudgetBox.get(Category.travel.name), budget2);

      // Deleting a non-existent budget should not throw an error
      await budgetRepository.deleteBudget(Category.health);
      expect(fakeBudgetBox.length, 1);
    });

    test(
      'watchAllBudgets emits budgets when the box changes (using emitsInOrder)',
      () async {
        final budget1 = Budget(category: Category.food, limit: 500.0);
        final budget2 = Budget(category: Category.travel, limit: 200.0);

        // Use expectLater to assert the stream's emissions over time
        expectLater(
          budgetRepository.watchAllBudgets(),
          emitsInOrder([
            [], // Initial emission (empty box)
            [budget1], // Emission after adding budget1
            [budget1, budget2], // Emission after adding budget2
          ]),
        );

        // Allow the initial emission to occur
        await pumpEventQueue();

        // Simulate adding budget1
        await fakeBudgetBox.add(budget1);
        await pumpEventQueue();

        // Simulate adding budget2
        await fakeBudgetBox.add(budget2);
        await pumpEventQueue();
      },
    );
  });
}
