import 'package:flutter/material.dart';
import 'package:fintrack_app/features/transactions/presentation/widgets/add_transaction_modal.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
      ),
      body: const Center(
        child: Text('Transactions Placeholder'),
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
