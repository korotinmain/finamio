import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/extensions/context_extensions.dart';
import '../../providers/goals_provider.dart';
import '../../providers/currency_provider.dart';
import '../../widgets/common/finamio_button.dart';

const _goalEmojis = [
  '🎯',
  '🏠',
  '🚗',
  '✈️',
  '💻',
  '📱',
  '👶',
  '🎓',
  '💍',
  '🏖️',
  '🏋️',
  '📚',
  '🎸',
  '🌱',
  '💎',
  '🚀',
  '🏦',
  '🎁',
  '⛵',
  '🏕️',
];

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String _emoji = '🎯';
  String _currency = 'USD';
  DateTime? _targetDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(goalsNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('New Goal')),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // ── Emoji picker ──────────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _pickEmoji,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: const Border.fromBorderSide(
                      BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                  child: Center(
                    child: Text(_emoji, style: const TextStyle(fontSize: 40)),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tap to change emoji',
                  style: AppTextStyles.caption,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Title ─────────────────────────────────────────────────────
            Text('Goal title', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'e.g. Emergency Fund',
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Description ───────────────────────────────────────────────
            Text('Description (optional)', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'What is this goal for?',
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Target amount ─────────────────────────────────────────────
            Text('Target amount', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final currencies = ref.read(supportedCurrenciesProvider);
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      builder:
                          (_) => ListView(
                            children:
                                currencies
                                    .map(
                                      (c) => ListTile(
                                        title: Text(c.code),
                                        subtitle: Text(c.name),
                                        onTap:
                                            () =>
                                                Navigator.pop(context, c.code),
                                      ),
                                    )
                                    .toList(),
                          ),
                    );
                    if (selected != null) {
                      setState(() => _currency = selected);
                    }
                  },
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

            const SizedBox(height: AppSpacing.xl),

            // ── Target date ───────────────────────────────────────────────
            Text('Target date (optional)', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
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
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _targetDate == null
                          ? 'No target date'
                          : 'by ${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            _targetDate == null
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                      ),
                    ),
                    if (_targetDate != null) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _targetDate = null),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            FinamioButton(
              label: 'Create Goal',
              onPressed: _save,
              isLoading: isLoading,
              gradient: AppColors.goalGradient,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _pickEmoji() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _goalEmojis.length,
              itemBuilder:
                  (_, i) => GestureDetector(
                    onTap: () => Navigator.pop(context, _goalEmojis[i]),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _goalEmojis[i],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
            ),
          ),
    );
    if (selected != null) setState(() => _emoji = selected);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      context.showSnack('Please enter a goal title', isError: true);
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      context.showSnack('Please enter a valid target amount', isError: true);
      return;
    }

    context.unfocus();

    final ok = await ref
        .read(goalsNotifierProvider.notifier)
        .addGoal(
          title: title,
          emoji: _emoji,
          targetAmount: amount,
          currency: _currency,
          description: _descController.text.trim(),
          targetDate: _targetDate,
        );

    if (ok && mounted) {
      context.showSnack('Goal created!');
      context.pop();
    }
  }
}
