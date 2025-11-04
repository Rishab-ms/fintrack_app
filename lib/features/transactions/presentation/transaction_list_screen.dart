import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/providers/core_providers.dart';
import 'package:fintrack_app/core/shared/constants.dart';
import 'package:fintrack_app/core/shared/utils/date_money_helpers.dart';
import 'package:fintrack_app/features/transactions/presentation/widgets/add_transaction_modal.dart';
import 'package:intl/intl.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactionsAsync = ref.watch(allTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
      ),
      body: allTransactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
              child: Text('No transactions yet. Click "+" to add one!'),
            );
          }

          // Group transactions by month
          final Map<String, List<Transaction>> groupedTransactions = {};
          for (var transaction in transactions) {
            final monthYear = DateFormat('MMMM yyyy').format(transaction.date);
            if (!groupedTransactions.containsKey(monthYear)) {
              groupedTransactions[monthYear] = [];
            }
            groupedTransactions[monthYear]!.add(transaction);
          }

          // Sort months in descending order
          final sortedMonths = groupedTransactions.keys.toList()
            ..sort((a, b) {
              final dateA = DateFormat('MMMM yyyy').parse(a);
              final dateB = DateFormat('MMMM yyyy').parse(b);
              return dateB.compareTo(dateA);
            });

          return ListView.builder(
            itemCount: sortedMonths.length,
            itemBuilder: (context, monthIndex) {
              final month = sortedMonths[monthIndex];
              final transactionsInMonth = groupedTransactions[month]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      month,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  ...transactionsInMonth.map((transaction) {
                    final isExpense =
                        transaction.type == TransactionType.expense;
                    final amountColor =
                        isExpense ? Colors.red : Colors.green;
                    final icon = isExpense
                        ? transaction.category?.icon ?? Icons.category
                        : Icons.attach_money; // Default icon for income

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColorLight,
                          child: Icon(icon,
                              color: Theme.of(context).primaryColorDark),
                        ),
                        title: Text(
                          transaction.description ??
                              (isExpense
                                  ? transaction.category?.displayName ??
                                      'Unknown Expense'
                                  : 'Income'),
                        ),
                        subtitle: Text(
                          '${formatDate(transaction.date)} - ${isExpense ? transaction.category?.displayName ?? 'N/A' : 'Income'}',
                        ),
                        trailing: Text(
                          formatCurrency(transaction.amount),
                          style: TextStyle(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showAddTransactionModal(context);
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
