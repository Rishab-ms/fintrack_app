import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/providers/core_providers.dart';
import 'package:fintrack_app/features/transactions/presentation/widgets/add_transaction_modal.dart';
import 'package:intl/intl.dart';
import 'package:fintrack_app/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:fintrack_app/config/app_theme.dart'; // Import AppSpacing

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactionsAsync = ref.watch(allTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Transactions',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: allTransactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Text(
                'No transactions yet. Click "+" to add one!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
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
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      month,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  ...transactionsInMonth.map((transaction) {
                    return TransactionCard(transaction: transaction);
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
        label: Text(
          'Add',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        icon: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
