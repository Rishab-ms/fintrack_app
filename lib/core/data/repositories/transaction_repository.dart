import 'package:hive_flutter/hive_flutter.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';


class TransactionRepository {
  final Box<Transaction> _transactionBox;

  TransactionRepository(this._transactionBox);

  /// Adds a new transaction to the Hive box.
  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  /// Clears all transactions from the Hive box.
  Future<void> clearAllTransactions() async {
    await _transactionBox.clear();
  }

  /// Returns a stream of all transactions, reacting to changes in the Hive box.
  Stream<List<Transaction>> watchAllTransactions() async* {
    // Emit the current list of transactions immediately
    yield _transactionBox.values.toList();

    // Then, yield new lists whenever the box changes
    await for (var event in _transactionBox.watch()) {
      yield _transactionBox.values.toList();
    }
  }
}
