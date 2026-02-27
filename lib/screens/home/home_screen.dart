import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/goal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/common/finamio_card.dart';
import '../../widgets/common/amount_display.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final symbol = ref.watch(baseCurrencySymbolProvider);
    final income = ref.watch(monthlyIncomeProvider);
    final expense = ref.watch(monthlyExpenseProvider);
    final balance = ref.watch(monthlyBalanceProvider);
    final savingsRate = ref.watch(savingsRateProvider);
    final recentTxs = ref.watch(recentTransactionsProvider);
    final goals = ref.watch(activeGoalsProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: AppColors.background,
            title: Row(
              children: [
                Text('finamio', style: AppTextStyles.headlineMedium),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    backgroundImage:
                        profile?.photoUrl != null
                            ? NetworkImage(profile!.photoUrl!)
                            : null,
                    child:
                        profile?.photoUrl == null
                            ? Text(
                              (profile?.displayName.isNotEmpty == true)
                                  ? profile!.displayName[0].toUpperCase()
                                  : 'U',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            )
                            : null,
                  ),
                ),
              ],
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Balance hero card ────────────────────────────────────
                GradientCard(
                  gradient: AppColors.primaryGradient,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppFormatters.formatMonthYear(selectedMonth),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Net Balance',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AmountDisplay(
                        amount: balance,
                        symbol: symbol,
                        style: AppTextStyles.amountHero.copyWith(
                          color: Colors.white,
                        ),
                        showSign: false,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStat(
                              label: 'Income',
                              amount: income,
                              symbol: symbol,
                              color: AppColors.income,
                              icon: Icons.arrow_downward_rounded,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          Expanded(
                            child: _MiniStat(
                              label: 'Expenses',
                              amount: expense,
                              symbol: symbol,
                              color: Colors.white70,
                              icon: Icons.arrow_upward_rounded,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          Expanded(
                            child: _MiniStat(
                              label: 'Saved',
                              amount: savingsRate,
                              symbol: '%',
                              color: AppColors.accent,
                              icon: Icons.savings_rounded,
                              isPercentage: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppSpacing.xxl),

                // ── Active goals ─────────────────────────────────────────
                if (goals.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Goals', style: AppTextStyles.headlineSmall),
                      TextButton(
                        onPressed: () => context.go('/goals'),
                        child: Text(
                          'See all',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: goals.take(5).length,
                      separatorBuilder:
                          (_, __) => const SizedBox(width: AppSpacing.md),
                      itemBuilder: (_, i) {
                        final goal = goals[i];
                        return _GoalChip(goal: goal, symbol: symbol)
                            .animate(delay: (i * 60).ms)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.1, end: 0);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                // ── Recent transactions ───────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent', style: AppTextStyles.headlineSmall),
                    TextButton(
                      onPressed: () => context.go('/transactions'),
                      child: Text(
                        'View all',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                recentTxs.when(
                  loading: () => _LoadingTransactions(),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (txs) {
                    if (txs.isEmpty) {
                      return _EmptyTransactions(
                        onAdd: () => context.push('/transactions/add'),
                      );
                    }
                    return FinamioCard(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children:
                            txs.take(8).map((tx) {
                              return TransactionTile(
                                transaction: tx,
                                currencySymbol: symbol,
                              );
                            }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/add'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: Text('Add', style: AppTextStyles.labelLarge),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.amount,
    required this.symbol,
    required this.color,
    required this.icon,
    this.isPercentage = false,
  });

  final String label;
  final double amount;
  final String symbol;
  final Color color;
  final IconData icon;
  final bool isPercentage;

  @override
  Widget build(BuildContext context) {
    final text =
        isPercentage
            ? AppFormatters.formatPercentage(amount)
            : AppFormatters.formatAmount(amount, symbol: symbol, compact: true);

    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          text,
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: Colors.white60),
        ),
      ],
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({required this.goal, required this.symbol});

  final Goal goal;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final pct = goal.progressPercentage;
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(goal.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  goal.title,
                  style: AppTextStyles.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            AppFormatters.formatPercentage(pct, decimals: 0),
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.goal),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: AppColors.goalSubtle,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goal),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Column(
        children: List.generate(
          4,
          (_) => Container(
            height: 60,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return FinamioCard(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text('💸', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('No transactions yet', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 6),
          Text('Tap + to add your first one.', style: AppTextStyles.bodySmall),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Transaction'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
