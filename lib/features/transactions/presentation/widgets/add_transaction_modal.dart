import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/providers/core_providers.dart';
import 'package:fintrack_app/core/shared/constants.dart';
import 'package:fintrack_app/core/shared/utils/date_money_helpers.dart';
import 'package:uuid/uuid.dart';
import 'package:fintrack_app/config/app_theme.dart'; // Import AppSpacing

class AddTransactionModal extends ConsumerStatefulWidget {
  const AddTransactionModal({super.key});

  @override
  ConsumerState<AddTransactionModal> createState() =>
      _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == TransactionType.expense && _selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select a category for expense.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final enteredAmount = double.parse(_amountController.text);

      final transactionRepository =
          await ref.read(transactionRepositoryProvider.future);
      final newTransaction = Transaction(
        id: const Uuid().v4(),
        amount: enteredAmount,
        date: _selectedDate,
        type: _selectedType,
        description: _descriptionController.text.trim(),
        category: _selectedType == TransactionType.expense
            ? _selectedCategory
            : null,
      );

      await transactionRepository.addTransaction(newTransaction);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Type Toggle (Income/Expense)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text(
                    'Expense',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _selectedType == TransactionType.expense
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  selected: _selectedType == TransactionType.expense,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = TransactionType.expense;
                      _selectedCategory =
                          null; // Reset category when switching to expense
                    });
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                ChoiceChip(
                  label: Text(
                    'Income',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _selectedType == TransactionType.income
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  selected: _selectedType == TransactionType.income,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = TransactionType.income;
                      _selectedCategory = null; // Income has no category
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              key: const Key('amount_text_field'),
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              decoration: InputDecoration(
                prefixText: '${formatCurrency(0).substring(0, 1)} ',
                labelText: 'Amount',
                labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount.';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid positive amount.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              key: const Key('description_text_field'),
              controller: _descriptionController,
              maxLength: 50,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              decoration: InputDecoration(
                labelText: 'What was this for?',
                labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Selected Date: ${formatDate(_selectedDate)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: _presentDatePicker,
                  icon: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Category Selector (only for Expense)
            if (_selectedType == TransactionType.expense)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Category:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm, // gap between adjacent chips
                    runSpacing: AppSpacing.sm, // gap between lines
                    children: Category.values
                        .map(
                          (category) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _selectedCategory == category
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.3)
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                  child: Icon(
                                    category.icon,
                                    color: _selectedCategory == category
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  category.displayName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: _selectedCategory == category
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitTransaction,
                  child: Text(
                    'Add Transaction',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Function to show the modal bottom sheet
void showAddTransactionModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: const AddTransactionModal(),
    ),
  );
}
