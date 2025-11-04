import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack_app/core/data/repositories/budget_repository.dart';
import 'package:fintrack_app/core/providers/core_providers.dart';
import 'package:fintrack_app/features/budgets/providers/budget_providers.dart';
import 'package:fintrack_app/features/budgets/presentation/widgets/budget_card.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:fintrack_app/config/app_theme.dart'; // Import AppSpacing

/// The main UI screen for displaying and managing monthly budgets.
///
/// This screen is a [ConsumerWidget] that watches the [budgetStatusProvider]
/// to get real-time updates on budget statuses for all expense categories.
/// It also watches [budgetRepositoryProvider] to interact with budget data.
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the budgetStatusProvider to get the current budget statuses.
    // This returns an AsyncValue, which handles loading, error, and data states.
    final budgetStatusAsync = ref.watch(budgetStatusProvider);
    // Watch the budgetRepositoryProvider to get access to CRUD operations.
    // It's a FutureProvider, so we access its future.
    final budgetRepositoryAsync = ref.watch(budgetRepositoryProvider.future);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Budgets',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
            Text(
              DateFormat.MMMM().format(DateTime.now()),
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: budgetStatusAsync.when(
        // When data is available, build the list of BudgetCards.
        data: (budgetStatuses) {
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: budgetStatuses.length,
            itemBuilder: (context, index) {
              final status = budgetStatuses[index];
              // Use FutureBuilder to wait for the BudgetRepository to be ready.
              return FutureBuilder<BudgetRepository>(
                future: budgetRepositoryAsync,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    // Once the repository is ready, build the BudgetCard.
                    return BudgetCard(
                      status: status,
                      budgetRepository: snapshot.data!,
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          );
        },
        // While data is loading, show a progress indicator.
        loading: () => const Center(child: CircularProgressIndicator()),
        // If an error occurs, display an error message.
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
