import 'package:fintrack_app/core/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/shared/utils/date_money_helpers.dart';
import 'package:fintrack_app/config/app_theme.dart'; // Import AppColors for semantic colors

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
  });

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final amountColor = isExpense
        ? (isDarkMode ? AppColors.expenseDark : AppColors.expenseLight)
        : (isDarkMode ? AppColors.incomeDark : AppColors.incomeLight);

    final icon = isExpense
        ? transaction.category?.icon ?? Icons.category
        : Icons.attach_money; // Default icon for income

    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardTheme.color,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (transaction.category?.color ??
                  Theme.of(context).colorScheme.surfaceVariant)
              .withOpacity(0.2),
          child: Icon(
            icon,
            color: transaction.category?.color ??
                Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Text(
          transaction.description ??
              (isExpense
                  ? transaction.category?.displayName ?? 'Unknown Expense'
                  : 'Income'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        subtitle: Text(
          '${formatDate(transaction.date)} - ${isExpense ? transaction.category?.displayName ?? 'N/A' : 'Income'}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        trailing: Text(
          formatCurrency(transaction.amount),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
