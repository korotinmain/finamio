import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/currency_provider.dart';
import '../../widgets/common/finamio_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(baseCurrencySymbolProvider);
    final dailySpend = ref.watch(dailySpendProvider);
    final expenseBreakdown = ref.watch(expenseBreakdownProvider);
    final income = ref.watch(monthlyIncomeProvider);
    final expense = ref.watch(monthlyExpenseProvider);
    final savingsRate = ref.watch(savingsRateProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppFormatters.formatMonthYear(selectedMonth))),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // ── Summary stat pills ────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Income',
                  value: AppFormatters.formatAmount(
                    income,
                    symbol: symbol,
                    compact: true,
                  ),
                  color: AppColors.income,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatPill(
                  label: 'Expenses',
                  value: AppFormatters.formatAmount(
                    expense,
                    symbol: symbol,
                    compact: true,
                  ),
                  color: AppColors.expense,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatPill(
                  label: 'Saved',
                  value: AppFormatters.formatPercentage(
                    savingsRate,
                    decimals: 0,
                  ),
                  color: AppColors.accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ── Daily bar chart ───────────────────────────────────────────────
          Text('Daily Cash Flow', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          FinamioCard(
            child: SizedBox(
              height: 200,
              child:
                  dailySpend.isEmpty
                      ? Center(
                        child: Text(
                          'No data this month',
                          style: AppTextStyles.bodySmall,
                        ),
                      )
                      : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          maxY: _maxValue(dailySpend, income, expense) * 1.2,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (
                                group,
                                groupIndex,
                                rod,
                                rodIndex,
                              ) {
                                final day = dailySpend[group.x.toInt()];
                                final isIncome = rodIndex == 0;
                                final value =
                                    isIncome ? day.income : day.expense;
                                if (value == 0) return null;
                                return BarTooltipItem(
                                  AppFormatters.formatAmount(
                                    value,
                                    symbol: symbol,
                                    compact: true,
                                  ),
                                  AppTextStyles.caption.copyWith(
                                    color:
                                        isIncome
                                            ? AppColors.income
                                            : AppColors.expense,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  final i = value.toInt();
                                  if (i % 5 != 0) {
                                    return const SizedBox.shrink();
                                  }
                                  if (i >= dailySpend.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    '${dailySpend[i].date.day}',
                                    style: AppTextStyles.caption,
                                  );
                                },
                                reservedSize: 22,
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval:
                                _maxValue(dailySpend, income, expense) / 4,
                            getDrawingHorizontalLine:
                                (_) => const FlLine(
                                  color: AppColors.divider,
                                  strokeWidth: 1,
                                ),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups:
                              dailySpend
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => BarChartGroupData(
                                      x: e.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: e.value.income,
                                          color: AppColors.income,
                                          width: 4,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(2),
                                              ),
                                        ),
                                        BarChartRodData(
                                          toY: e.value.expense,
                                          color: AppColors.expense,
                                          width: 4,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(2),
                                              ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ── Expense breakdown ─────────────────────────────────────────────
          Text('Expense Breakdown', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.md),

          if (expenseBreakdown.isEmpty)
            FinamioCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No expenses this month',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
            )
          else ...[
            // Donut chart
            FinamioCard(
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 60,
                    sections:
                        expenseBreakdown.take(6).map((b) {
                          return PieChartSectionData(
                            value: b.amount,
                            color: _categoryColor(expenseBreakdown.indexOf(b)),
                            radius: 36,
                            title: b.category.emoji,
                            titleStyle: const TextStyle(fontSize: 16),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Legend
            FinamioCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children:
                    expenseBreakdown.take(6).map((b) {
                      final i = expenseBreakdown.indexOf(b);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _categoryColor(i),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              b.category.emoji,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              b.category.label,
                              style: AppTextStyles.bodyMedium,
                            ),
                            const Spacer(),
                            Text(
                              AppFormatters.formatAmount(
                                b.amount,
                                symbol: symbol,
                                compact: true,
                              ),
                              style: AppTextStyles.titleMedium.copyWith(
                                color: _categoryColor(i),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppFormatters.formatPercentage(
                                b.percentage,
                                decimals: 0,
                              ),
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  double _maxValue(dailySpend, double income, double expense) {
    double max = 0;
    for (final d in dailySpend) {
      if (d.income > max) max = d.income.toDouble();
      if (d.expense > max) max = d.expense.toDouble();
    }
    return max > 0 ? max : 100;
  }

  static const _chartColors = [
    AppColors.expense,
    AppColors.goal,
    AppColors.warning,
    AppColors.accent,
    AppColors.income,
    AppColors.primary,
  ];

  Color _categoryColor(int index) => _chartColors[index % _chartColors.length];
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.titleMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}
