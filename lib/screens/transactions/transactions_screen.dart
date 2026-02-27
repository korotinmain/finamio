import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/currency_provider.dart';
import '../../widgets/common/amount_display.dart';
import '../../widgets/common/finamio_card.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final txsAsync = ref.watch(transactionsStreamProvider);
    final income = ref.watch(monthlyIncomeProvider);
    final expense = ref.watch(monthlyExpenseProvider);
    final symbol = ref.watch(baseCurrencySymbolProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/transactions/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Month navigation ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed:
                      () =>
                          ref
                              .read(selectedMonthProvider.notifier)
                              .state = DateTime(
                            selectedMonth.year,
                            selectedMonth.month - 1,
                          ),
                ),
                Column(
                  children: [
                    Text(
                      AppFormatters.formatMonthYear(selectedMonth),
                      style: AppTextStyles.titleLarge,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () {
                    final next = DateTime(
                      selectedMonth.year,
                      selectedMonth.month + 1,
                    );
                    if (next.isBefore(
                      DateTime.now().add(const Duration(days: 1)),
                    )) {
                      ref.read(selectedMonthProvider.notifier).state = next;
                    }
                  },
                ),
              ],
            ),
          ),

          // ── Income / Expense cards ─────────────────────────────────────────
          Padding(
            padding: AppSpacing.pagePadding,
            child: Row(
              children: [
                Expanded(
                  child: FinamioCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    borderColor: AppColors.incomeSubtle,
                    shadows: AppSpacing.incomeShadow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_downward_rounded,
                              color: AppColors.income,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Income',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.income,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AmountDisplay(
                          amount: income,
                          symbol: symbol,
                          style: AppTextStyles.amountMedium.copyWith(
                            color: AppColors.income,
                          ),
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FinamioCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    borderColor: AppColors.expenseSubtle,
                    shadows: AppSpacing.expenseShadow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              color: AppColors.expense,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Expenses',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AmountDisplay(
                          amount: expense,
                          symbol: symbol,
                          style: AppTextStyles.amountMedium.copyWith(
                            color: AppColors.expense,
                          ),
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Transactions list ─────────────────────────────────────────────
          Expanded(
            child: txsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (txs) {
                if (txs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📭', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions this month',
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/transactions/add'),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Transaction'),
                        ),
                      ],
                    ),
                  );
                }

                // Group by date
                final Map<String, List<FinancialTransaction>> grouped = {};
                for (final tx in txs) {
                  final key = AppFormatters.formatDate(tx.date);
                  grouped.putIfAbsent(key, () => []).add(tx);
                }

                return ListView.builder(
                  padding: AppSpacing.pagePadding,
                  itemCount: grouped.length,
                  itemBuilder: (_, i) {
                    final date = grouped.keys.elementAt(i);
                    final dayTxs = grouped[date]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          child: Text(date, style: AppTextStyles.labelMedium),
                        ),
                        FinamioCard(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children:
                                dayTxs
                                    .map(
                                      (tx) => TransactionTile(
                                        transaction: tx,
                                        currencySymbol: symbol,
                                        onLongPress:
                                            () => _confirmDelete(
                                              context,
                                              ref,
                                              tx.id,
                                            ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete transaction'),
            content: const Text(
              'Are you sure you want to delete this transaction?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.expense),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await ref
          .read(transactionsNotifierProvider.notifier)
          .deleteTransaction(id);
    }
  }
}
