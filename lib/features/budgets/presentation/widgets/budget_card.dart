import 'package:fintrack_app/core/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack_app/core/data/models/budget_model.dart';
import 'package:fintrack_app/core/data/repositories/budget_repository.dart';
import 'package:fintrack_app/core/shared/utils/date_money_helpers.dart';
import 'package:fintrack_app/features/budgets/providers/budget_providers.dart';
import 'package:fintrack_app/config/app_theme.dart'; // Import AppColors for semantic colors

/// A widget that displays a single budget category's status and allows editing its limit.
///
/// This is a [ConsumerStatefulWidget] because it manages a [TextEditingController]
/// for the budget limit input and needs to react to changes in the global
/// editing state via [editingBudgetCategoryProvider].
class BudgetCard extends ConsumerStatefulWidget {
  final BudgetStatus status;
  final BudgetRepository budgetRepository;

  const BudgetCard({
    super.key,
    required this.status,
    required this.budgetRepository,
  });

  @override
  ConsumerState<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends ConsumerState<BudgetCard> {
  final TextEditingController _limitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text field with the current budget limit.
    _limitController.text = widget.status.limit.toStringAsFixed(2);
  }

  @override
  void didUpdateWidget(covariant BudgetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This method is called when the widget's configuration changes.
    // We update the text field's value if the budget limit has changed
    // and the card is not currently in editing mode. This prevents
    // overwriting user input while they are actively typing.
    final isCurrentlyEditingThisCard = ref.read(editingBudgetCategoryProvider) == widget.status.category;
    if (!isCurrentlyEditingThisCard && oldWidget.status.limit != widget.status.limit) {
      _limitController.text = widget.status.limit.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  /// Determines the color of the progress bar based on the percentage of budget used.
  ///
  /// - Red: 90% or more used (critical)
  /// - Orange: 70% to 89% used (warning)
  /// - Green: Less than 70% used (safe)
  Color _getProgressBarColor(double percentage, Brightness brightness) {
    if (percentage >= 0.9) {
      return brightness == Brightness.dark ? AppColors.dangerDark : AppColors.dangerLight;
    } else if (percentage >= 0.7) {
      return brightness == Brightness.dark ? AppColors.warningDark : AppColors.warningLight;
    } else {
      return brightness == Brightness.dark ? AppColors.incomeDark : AppColors.incomeLight;
    }
  }

  /// Saves the new budget limit entered by the user.
  ///
  /// 1. Parses the input from `_limitController`.
  /// 2. Validates that the input is a non-negative number.
  /// 3. Creates a new [Budget] object with the updated limit.
  /// 4. Calls `budgetRepository.saveBudget` to persist the change.
  /// 5. Resets the `editingBudgetCategoryProvider` to `null` to exit edit mode
  ///    for this budget card.
  /// 6. Shows a [SnackBar] if the input is invalid.
  Future<void> _saveLimit() async {
    final newLimit = double.tryParse(_limitController.text);
    if (newLimit != null && newLimit >= 0) {
      final newBudget = Budget(
        category: widget.status.category,
        limit: newLimit,
      );
      await widget.budgetRepository.saveBudget(newBudget);
      ref.read(editingBudgetCategoryProvider.notifier).state = null; // Exit edit mode
    } else {
      // Show error or alert
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid number for the limit.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    final brightness = Theme.of(context).brightness;
    final progressBarColor = _getProgressBarColor(status.percentageUsed, brightness);
    // Watch the global editing state to determine if this card should be in edit mode.
    final editingCategory = ref.watch(editingBudgetCategoryProvider);
    final isEditing = editingCategory == status.category;

    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardTheme.color,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status.category.icon,
                  color: status.category.color,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  status.category.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const Spacer(),
                // Toggle between "Save" (check icon) and "Edit" icon based on `isEditing` state.
                isEditing
                    ? IconButton(
                        icon: Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _saveLimit, // Call _saveLimit when check is pressed
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          // Set this category as the one being edited globally.
                          // This will cause other BudgetCards to rebuild and exit edit mode.
                          ref.read(editingBudgetCategoryProvider.notifier).state = status.category;
                          // Update the text field with the current limit when entering edit mode.
                          // This ensures the user sees the current value before editing.
                          _limitController.text = status.limit.toStringAsFixed(2);
                        },
                      ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Display TextField for editing or Text for displaying, based on `isEditing`.
            isEditing
                ? TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    decoration: InputDecoration(
                      labelText: 'Monthly Limit',
                      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      prefixText: formatCurrency(0).substring(0, 1), // Get currency symbol
                      prefixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
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
                  )
                : Text(
                    '${formatCurrency(status.spent)} of ${formatCurrency(status.limit)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
            const SizedBox(height: AppSpacing.sm),
            /// Linear progress indicator showing budget usage.
            /// Value is clamped between 0.0 and 1.0 to prevent visual issues with overspending.
            LinearProgressIndicator(
              value: status.percentageUsed.clamp(0.0, 1.0),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              color: progressBarColor,
              minHeight: 10,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(status.percentageUsed * 100).toStringAsFixed(0)}% used',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  '${formatCurrency(status.amountRemaining)} left',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            // Conditional alert message when budget usage is high or exceeded.
            if (status.percentageUsed >= 0.8 && status.limit > 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  status.percentageUsed >= 1.0
                      ? 'Budget exceeded!'
                      : 'You\'re close to your budget limit!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: progressBarColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
