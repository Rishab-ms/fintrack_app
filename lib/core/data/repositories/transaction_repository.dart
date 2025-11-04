import 'package:hive_flutter/hive_flutter.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/data/services/hive_service.dart';

class TransactionRepository {
  final HiveService _hiveService;

  TransactionRepository(this._hiveService);

  Box<Transaction> get _transactionBox => _hiveService.transactionBox;

  /// Adds a new transaction to the Hive box.
  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  /// Returns a stream of all transactions, reacting to changes in the Hive box.
  Stream<List<Transaction>> watchAllTransactions() {
    return _transactionBox.watch().map(
      (event) => _transactionBox.values.toList(),
    );
  }
}
