import 'package:hive_flutter/hive_flutter.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/data/models/budget_model.dart';
import 'package:fintrack_app/core/shared/constants.dart';

class HiveService {
  late Box<Transaction> transactionBox;
  late Box<Budget> budgetBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(BudgetAdapter());
  }

  Future<void> openBoxes() async {
    transactionBox = await Hive.openBox<Transaction>('transactions');
    budgetBox = await Hive.openBox<Budget>('budgets');
  }

  Future<void> closeBoxes() async {
    await transactionBox.close();
    await budgetBox.close();
  }
}
