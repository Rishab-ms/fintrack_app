import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/providers/core_providers.dart';
import 'package:fintrack_app/core/shared/constants.dart';
import 'package:fintrack_app/core/shared/utils/date_money_helpers.dart';
import 'package:uuid/uuid.dart';

class AddTransactionModal extends ConsumerStatefulWidget {
  const AddTransactionModal({super.key});

  @override
  ConsumerState<AddTransactionModal> createState() =>
      _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
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
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitTransaction() async {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;

    if (amountIsInvalid) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text(
            'Please make sure a valid amount was entered.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Type Toggle (Income/Expense)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Expense'),
                selected: _selectedType == TransactionType.expense,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = TransactionType.expense;
                    _selectedCategory =
                        null; // Reset category when switching to expense
                  });
                },
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Income'),
                selected: _selectedType == TransactionType.income,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = TransactionType.income;
                    _selectedCategory = null; // Income has no category
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('amount_text_field'),
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: '₹ ',
              labelText: 'Amount',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('description_text_field'),
            controller: _descriptionController,
            maxLength: 50,
            decoration: const InputDecoration(labelText: 'What was this for?'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('Selected Date: ${formatDate(_selectedDate)}'),
              ),
              IconButton(
                onPressed: _presentDatePicker,
                icon: const Icon(Icons.calendar_month),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Category Selector (only for Expense)
          if (_selectedType == TransactionType.expense)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Category:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0, // gap between adjacent chips
                  runSpacing: 8.0, // gap between lines
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
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withAlpha((255 * 0.3).round())
                                    : Colors.grey.shade200,
                                child: Icon(
                                  category.icon,
                                  color: _selectedCategory == category
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _selectedCategory == category
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade700,
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _submitTransaction,
                child: const Text('Add Transaction'),
              ),
            ],
          ),
        ],
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
