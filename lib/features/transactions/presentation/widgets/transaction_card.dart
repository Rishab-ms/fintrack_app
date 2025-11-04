import 'package:fintrack_app/core/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import for ConsumerWidget
import 'package:fintrack_app/core/data/repositories/transaction_repository.dart'; // Import for transactionRepositoryProvider
import 'package:fintrack_app/core/providers/core_providers.dart'; // Import for transactionRepositoryProvider
import 'package:fintrack_app/core/shared/utils/date_money_helpers.dart';
import 'package:fintrack_app/config/app_theme.dart'; // Import AppColors for semantic colors
import 'package:fintrack_app/features/transactions/presentation/widgets/add_transaction_modal.dart'; // Import AddTransactionModal

class TransactionCard extends ConsumerWidget {
  const TransactionCard({super.key, required this.transaction});

  final Transaction transaction;

  void _showTransactionOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Transaction'),
                onTap: () {
                  Navigator.pop(ctx); // Close the bottom sheet
                  showAddTransactionModal(
                    context,
                    transactionToEdit: transaction,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Transaction'),
                onTap: () async {
                  Navigator.pop(ctx); // Close the bottom sheet
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Delete Transaction'),
                      content: const Text(
                        'Are you sure you want to delete this transaction?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogCtx).pop(false);
                          },
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onError,
                          ),
                          onPressed: () {
                            Navigator.of(dialogCtx).pop(true);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final transactionRepository = await ref.read(
                      transactionRepositoryProvider.future,
                    );
                    await transactionRepository.deleteTransaction(
                      transaction.id,
                    );
                    // Optionally show a snackbar or refresh the list
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = transaction.type == TransactionType.expense;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final amountColor = isExpense
        ? (isDarkMode ? AppColors.expenseDark : AppColors.expenseLight)
        : (isDarkMode ? AppColors.incomeDark : AppColors.incomeLight);

    final icon = isExpense
        ? transaction.category?.icon ?? Icons.category
        : Icons.attach_money; // Default icon for income

    return InkWell(
      onLongPress: () => _showTransactionOptions(context, ref),
      child: Card(
        elevation: Theme.of(context).cardTheme.elevation,
        shape: Theme.of(context).cardTheme.shape,
        color: Theme.of(context).cardTheme.color,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                (transaction.category?.color ??
                        Theme.of(context).colorScheme.surfaceVariant)
                    .withOpacity(0.2),
            child: Icon(
              icon,
              color:
                  transaction.category?.color ??
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
      ),
    );
  }
}
