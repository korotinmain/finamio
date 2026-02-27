import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/transaction.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/currency_service.dart';
import '../../widgets/common/finamio_button.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.food;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  String _currency = 'USD';

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<TransactionCategory> get _filteredCategories =>
      TransactionCategory.values
          .where(
            (c) =>
                _type == TransactionType.expense ? c.isExpense : !c.isExpense,
          )
          .toList();

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(transactionsNotifierProvider);
    final isLoading = notifier.isLoading;
    final currencies = ref.watch(supportedCurrenciesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // ── Type toggle ──────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: const Border.fromBorderSide(
                  BorderSide(color: AppColors.cardBorder),
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children:
                    TransactionType.values.map((t) {
                      final selected = _type == t;
                      final isIncome = t == TransactionType.income;
                      return Expanded(
                        child: GestureDetector(
                          onTap:
                              () => setState(() {
                                _type = t;
                                _category = _filteredCategories.first;
                              }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient:
                                  selected
                                      ? (isIncome
                                          ? AppColors.incomeGradient
                                          : AppColors.expenseGradient)
                                      : null,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isIncome
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  size: 16,
                                  color:
                                      selected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isIncome ? 'Income' : 'Expense',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color:
                                        selected
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Amount ───────────────────────────────────────────────────
            Text('Amount', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                // Currency picker
                GestureDetector(
                  onTap: () => _pickCurrency(currencies),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: const Border.fromBorderSide(
                        BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    child: Text(
                      _currency,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    style: AppTextStyles.amountLarge,
                    decoration: const InputDecoration(hintText: '0.00'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Category ─────────────────────────────────────────────────
            Text('Category', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children:
                  _filteredCategories.map((cat) {
                    final selected = _category == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _category = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selected
                                  ? AppColors.primary.withOpacity(0.2)
                                  : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                          border: Border.all(
                            color:
                                selected
                                    ? AppColors.primary
                                    : AppColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              cat.emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat.label,
                              style: AppTextStyles.labelMedium.copyWith(
                                color:
                                    selected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Date ─────────────────────────────────────────────────────
            Text('Date', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: const Border.fromBorderSide(
                    BorderSide(color: AppColors.cardBorder),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Text(_dateLabel, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Note ─────────────────────────────────────────────────────
            Text('Note (optional)', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _noteController,
              maxLength: 120,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'What was this for?',
                counterText: '',
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // ── Save ─────────────────────────────────────────────────────
            FinamioButton(
              label: 'Save Transaction',
              onPressed: _save,
              isLoading: isLoading,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String get _dateLabel {
    final today = DateTime.now();
    if (_date.year == today.year &&
        _date.month == today.month &&
        _date.day == today.day)
      return 'Today';
    return '${_date.day}/${_date.month}/${_date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: Theme.of(
                ctx,
              ).colorScheme.copyWith(primary: AppColors.primary),
            ),
            child: child!,
          ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickCurrency(List<Currency> currencies) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder:
          (_) => _CurrencyPicker(currencies: currencies, selected: _currency),
    );
    if (selected != null) setState(() => _currency = selected);
  }

  Future<void> _save() async {
    final rawAmount = double.tryParse(_amountController.text.trim());
    if (rawAmount == null || rawAmount <= 0) {
      context.showSnack('Please enter a valid amount', isError: true);
      return;
    }

    context.unfocus();

    final ok = await ref
        .read(transactionsNotifierProvider.notifier)
        .addTransaction(
          type: _type,
          category: _category,
          amount: rawAmount,
          currency: _currency,
          note: _noteController.text.trim(),
          date: _date,
        );

    if (ok && mounted) {
      context.showSnack('Transaction saved!');
      context.pop();
    } else if (mounted) {
      context.showSnack('Failed to save. Try again.', isError: true);
    }
  }
}

class _CurrencyPicker extends StatelessWidget {
  const _CurrencyPicker({required this.currencies, required this.selected});

  final List<Currency> currencies;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Select Currency', style: AppTextStyles.headlineSmall),
        ),
        ...currencies.map(
          (c) => ListTile(
            leading: Text(
              c.symbol,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            title: Text(c.code, style: AppTextStyles.titleMedium),
            subtitle: Text(c.name, style: AppTextStyles.bodySmall),
            trailing:
                c.code == selected
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
            onTap: () => Navigator.pop(context, c.code),
          ),
        ),
      ],
    );
  }
}
