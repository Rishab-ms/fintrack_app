import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/shared/constants.dart';
import 'package:fintrack_app/core/providers/core_providers.dart';

/// Represents the financial overview data for the dashboard.
class BalanceData {
  final double currentBalance;
  final double monthlyIncome;
  final double monthlyExpenses;

  BalanceData({
    required this.currentBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
  });
}

/// Represents a segment in the expense distribution pie chart.
class ChartSegment {
  final Category category;
  final double value;
  final Color color;

  ChartSegment({
    required this.category,
    required this.value,
    required this.color,
  });
}

/// Provides the overall balance, monthly income, and monthly expenses.
final dashboardBalanceProvider = Provider<BalanceData>((ref) {
  final allTransactions = ref.watch(allTransactionsProvider).value ?? [];

  double totalIncome = 0;
  double totalExpenses = 0;
  double currentMonthIncome = 0;
  double currentMonthExpenses = 0;

  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);

  for (final transaction in allTransactions) {
    if (transaction.type == TransactionType.income) {
      totalIncome += transaction.amount;
      if (DateTime(transaction.date.year, transaction.date.month) == currentMonth) {
        currentMonthIncome += transaction.amount;
      }
    } else {
      totalExpenses += transaction.amount;
      if (DateTime(transaction.date.year, transaction.date.month) == currentMonth) {
        currentMonthExpenses += transaction.amount;
      }
    }
  }

  final currentBalance = totalIncome - totalExpenses;

  return BalanceData(
    currentBalance: currentBalance,
    monthlyIncome: currentMonthIncome,
    monthlyExpenses: currentMonthExpenses,
  );
});

/// Provides data for the expense distribution chart for the current month.
final chartDataProvider = Provider<List<ChartSegment>>((ref) {
  final allTransactions = ref.watch(allTransactionsProvider).value ?? [];

  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);

  final Map<Category, double> categoryExpenses = {};

  for (final transaction in allTransactions) {
    if (transaction.type == TransactionType.expense &&
        DateTime(transaction.date.year, transaction.date.month) == currentMonth) {
      if (transaction.category != null) {
        categoryExpenses.update(
          transaction.category!,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }
  }

  return categoryExpenses.entries.map((entry) {
    return ChartSegment(
      category: entry.key,
      value: entry.value,
      color: entry.key.color, // Using the color extension
    );
  }).toList();
});
