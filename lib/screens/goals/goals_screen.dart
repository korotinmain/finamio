import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/goal.dart';
import '../../providers/goals_provider.dart';
import '../../providers/currency_provider.dart';
import '../../widgets/common/finamio_card.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);
    final symbol = ref.watch(baseCurrencySymbolProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/goals/add'),
          ),
        ],
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 20),
                  Text('No goals yet', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Start saving towards something great.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/goals/add'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Goal'),
                  ),
                ],
              ),
            );
          }

          final active =
              goals.where((g) => g.status == GoalStatus.active).toList();
          final completed =
              goals.where((g) => g.status == GoalStatus.completed).toList();

          return ListView(
            padding: AppSpacing.pagePadding,
            children: [
              if (active.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Active (${active.length})',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ...active.asMap().entries.map(
                  (e) => _GoalCard(goal: e.value, symbol: symbol, ref: ref)
                      .animate(delay: (e.key * 60).ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                ),
              ],
              if (completed.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Completed 🏆 (${completed.length})',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ...completed.map(
                  (g) => _GoalCard(goal: g, symbol: symbol, ref: ref),
                ),
              ],
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.symbol,
    required this.ref,
  });

  final Goal goal;
  final String symbol;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isCompleted = goal.status == GoalStatus.completed;
    final pct = goal.progressPercentage / 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: FinamioCard(
        borderColor:
            isCompleted
                ? AppColors.income.withOpacity(0.4)
                : AppColors.cardBorder,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title, style: AppTextStyles.titleLarge),
                      if (goal.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          goal.description!,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.income,
                    size: 22,
                  ),
                if (!isCompleted) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    onPressed: () => _addFunds(context),
                    tooltip: 'Add funds',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.expense,
                      size: 22,
                    ),
                    onPressed: () => _confirmDelete(context),
                    tooltip: 'Delete',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppFormatters.formatAmount(
                    goal.currentAmount,
                    symbol: symbol,
                  ),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.goal,
                  ),
                ),
                Text(
                  'of ${AppFormatters.formatAmount(goal.targetAmount, symbol: symbol)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearPercentIndicator(
              percent: pct.clamp(0.0, 1.0),
              lineHeight: 8,
              backgroundColor: AppColors.goalSubtle,
              progressColor: isCompleted ? AppColors.income : AppColors.goal,
              barRadius: const Radius.circular(99),
              padding: EdgeInsets.zero,
              animation: true,
              animationDuration: 800,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppFormatters.formatPercentage(
                    goal.progressPercentage,
                    decimals: 0,
                  ),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isCompleted ? AppColors.income : AppColors.goal,
                  ),
                ),
                if (goal.targetDate != null)
                  Text(
                    'by ${AppFormatters.formatDate(goal.targetDate!)}',
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addFunds(BuildContext context) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add funds'),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'Amount',
                prefixText: symbol,
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Add'),
              ),
            ],
          ),
    );
    if (ok == true) {
      final amount = double.tryParse(controller.text.trim());
      if (amount != null && amount > 0) {
        await ref.read(goalsNotifierProvider.notifier).addFunds(goal, amount);
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete goal'),
            content: Text('Delete "${goal.title}"? This cannot be undone.'),
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
      await ref.read(goalsNotifierProvider.notifier).deleteGoal(goal.id);
    }
  }
}
