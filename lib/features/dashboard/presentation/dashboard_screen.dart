import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack_app/core/data/models/transaction_model.dart';
import 'package:fintrack_app/core/providers/core_providers.dart';
import 'package:fintrack_app/core/shared/constants.dart';
import 'package:fintrack_app/core/shared/utils/date_money_helpers.dart';
import 'package:fintrack_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:fintrack_app/features/transactions/presentation/transaction_list_screen.dart'; // For "View All" navigation
import 'package:fintrack_app/main.dart'; // Import main.dart to access themeModeProvider

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactionsStream = ref.watch(allTransactionsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FinTrack',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'download_csv') {
                // TODO: Implement CSV download functionality
              } else if (value == 'toggle_dark_mode') {
                ref.read(themeModeProvider.notifier).state =
                    themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
              }
            },
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'download_csv',
                child: Row(
                  children: [
                    Icon(
                      Icons.download,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Download CSV',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'toggle_dark_mode',
                child: Row(
                  children: [
                    Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      themeMode == ThemeMode.dark
                          ? 'Toggle Light Mode'
                          : 'Toggle Dark Mode',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: allTransactionsStream.when(
        data: (transactions) {
          final balanceData = ref.watch(dashboardBalanceProvider);
          final chartData = ref.watch(chartDataProvider);
          final recentTransactions =
              transactions
                  .where(
                    (t) => t.date.isBefore(DateTime.now()),
                  ) // Filter out future transactions
                  .toList()
                ..sort(
                  (a, b) => b.date.compareTo(a.date),
                ); // Sort by date descending

          final displayTransactions = recentTransactions
              .take(5)
              .toList(); // Take top 5

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Current Balance Card
              Card(
                elevation: Theme.of(context).cardTheme.elevation,
                shape: Theme.of(context).cardTheme.shape,
                color: Theme.of(context).cardTheme.color,
                margin: Theme.of(context).cardTheme.margin,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Balance',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatCurrency(balanceData.currentBalance),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBalanceDetail(
                            context,
                            'Income',
                            balanceData.monthlyIncome,
                            Theme.of(context).colorScheme.secondary,
                          ),
                          _buildBalanceDetail(
                            context,
                            'Expenses',
                            balanceData.monthlyExpenses,
                            Theme.of(context).colorScheme.error,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Expense Distribution Card
              if (chartData.isEmpty)
                Card(
                  elevation: Theme.of(context).cardTheme.elevation,
                  shape: Theme.of(context).cardTheme.shape,
                  color: Theme.of(context).cardTheme.color,
                  margin: Theme.of(context).cardTheme.margin,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'No expenses for the current month to display chart.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                  ),
                )
              else
                Card(
                  elevation: Theme.of(context).cardTheme.elevation,
                  shape: Theme.of(context).cardTheme.shape,
                  color: Theme.of(context).cardTheme.color,
                  margin: Theme.of(context).cardTheme.margin,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expense Distribution (Current Month)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: chartData.map((segment) {
                                final isTouched =
                                    false; // No touch interaction for now
                                final double radius = isTouched ? 60 : 50;
                                final totalMonthlyExpenses = chartData.fold(
                                  0.0,
                                  (sum, item) => sum + item.value,
                                );
                                return PieChartSectionData(
                                  color: segment.color,
                                  value: segment.value,
                                  title:
                                      '${(segment.value / totalMonthlyExpenses * 100).toStringAsFixed(1)}%',
                                  radius: radius,
                                  titleStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                  badgeWidget: null, // No badge for now
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: chartData.map((segment) {
                            return _LegendWidget(
                              color: segment.color,
                              title: segment.category.displayName,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Recent Transactions Card
              Card(
                elevation: Theme.of(context).cardTheme.elevation,
                shape: Theme.of(context).cardTheme.shape,
                color: Theme.of(context).cardTheme.color,
                margin: Theme.of(context).cardTheme.margin,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TransactionListScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'View All',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (displayTransactions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: Text(
                              'No recent transactions.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                        )
                      else
                        ...displayTransactions.map((transaction) {
                          return _buildTransactionItem(context, transaction);
                        }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBalanceDetail(
    BuildContext context,
    String title,
    double amount,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          formatCurrency(amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.secondary;
    final sign = isExpense ? '-' : '+';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (transaction.category?.color ??
                    Theme.of(context).colorScheme.surfaceVariant)
                .withOpacity(0.2),
            child: Icon(
              transaction.category?.icon ?? Icons.attach_money,
              color: transaction.category?.color ??
                  Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ??
                      (isExpense
                          ? transaction.category?.displayName ?? 'Expense'
                          : 'Income'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${formatDate(transaction.date)} ${isExpense ? '• ${transaction.category?.displayName ?? ''}' : ''}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '$sign ${formatCurrency(transaction.amount)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _LegendWidget extends StatelessWidget {
  const _LegendWidget({required this.color, required this.title});

  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}
