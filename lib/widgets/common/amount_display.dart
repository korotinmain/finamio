import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction.dart';

/// Large balance / amount number display with animated sign colouring
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    required this.symbol,
    this.style,
    this.showSign = false,
    this.colored = false,
    this.compact = false,
  });

  final double amount;
  final String symbol;
  final TextStyle? style;
  final bool showSign;
  final bool colored;
  final bool compact;

  Color get _color {
    if (!colored) return AppColors.textPrimary;
    return amount >= 0 ? AppColors.income : AppColors.expense;
  }

  @override
  Widget build(BuildContext context) {
    final text = AppFormatters.formatAmount(
      amount,
      symbol: symbol,
      compact: compact,
      showSign: showSign,
    );

    return Text(
      text,
      style: (style ?? AppTextStyles.amountHero).copyWith(color: _color),
    );
  }
}

/// Transaction list tile
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currencySymbol,
    this.onTap,
    this.onLongPress,
  });

  final FinancialTransaction transaction;
  final String currencySymbol;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final bgColor = isIncome ? AppColors.incomeSubtle : AppColors.expenseSubtle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    transaction.category.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category.label,
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.note?.isNotEmpty == true
                          ? transaction.note!
                          : AppFormatters.formatRelativeDate(transaction.date),
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.formatAmount(
                      transaction.amount,
                      symbol: currencySymbol,
                      showSign: true,
                    ).replaceFirst('+', isIncome ? '+' : ''),
                    style: AppTextStyles.titleMedium.copyWith(color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormatters.formatShortDate(transaction.date),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
