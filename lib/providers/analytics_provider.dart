import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import 'transactions_provider.dart';

class CategoryBreakdown {
  final TransactionCategory category;
  final double amount;
  final double percentage;

  const CategoryBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class DailySpend {
  final DateTime date;
  final double income;
  final double expense;

  const DailySpend({
    required this.date,
    required this.income,
    required this.expense,
  });
}

// ── Category breakdown ────────────────────────────────────────────────────────

final expenseBreakdownProvider = Provider<List<CategoryBreakdown>>((ref) {
  final txs = ref.watch(transactionsStreamProvider).valueOrNull ?? [];
  final expenses = txs.where((t) => t.type == TransactionType.expense);
  final total = expenses.fold(0.0, (sum, t) => sum + t.amountInBaseCurrency);

  if (total == 0) return [];

  final Map<TransactionCategory, double> map = {};
  for (final t in expenses) {
    map[t.category] = (map[t.category] ?? 0) + t.amountInBaseCurrency;
  }

  final items =
      map.entries
          .map(
            (e) => CategoryBreakdown(
              category: e.key,
              amount: e.value,
              percentage: e.value / total * 100,
            ),
          )
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

  return items;
});

final incomeBreakdownProvider = Provider<List<CategoryBreakdown>>((ref) {
  final txs = ref.watch(transactionsStreamProvider).valueOrNull ?? [];
  final incomes = txs.where((t) => t.type == TransactionType.income);
  final total = incomes.fold(0.0, (sum, t) => sum + t.amountInBaseCurrency);

  if (total == 0) return [];

  final Map<TransactionCategory, double> map = {};
  for (final t in incomes) {
    map[t.category] = (map[t.category] ?? 0) + t.amountInBaseCurrency;
  }

  return map.entries
      .map(
        (e) => CategoryBreakdown(
          category: e.key,
          amount: e.value,
          percentage: e.value / total * 100,
        ),
      )
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));
});

// ── Daily spend ───────────────────────────────────────────────────────────────

final dailySpendProvider = Provider<List<DailySpend>>((ref) {
  final txs = ref.watch(transactionsStreamProvider).valueOrNull ?? [];
  final month = ref.watch(selectedMonthProvider);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

  final Map<int, DailySpend> map = {};
  for (var day = 1; day <= daysInMonth; day++) {
    map[day] = DailySpend(
      date: DateTime(month.year, month.month, day),
      income: 0,
      expense: 0,
    );
  }

  for (final t in txs) {
    final day = t.date.day;
    if (map[day] == null) continue;
    final current = map[day]!;
    if (t.type == TransactionType.income) {
      map[day] = DailySpend(
        date: current.date,
        income: current.income + t.amountInBaseCurrency,
        expense: current.expense,
      );
    } else {
      map[day] = DailySpend(
        date: current.date,
        income: current.income,
        expense: current.expense + t.amountInBaseCurrency,
      );
    }
  }

  return map.values.toList()..sort((a, b) => a.date.compareTo(b.date));
});

// ── Savings rate ──────────────────────────────────────────────────────────────

final savingsRateProvider = Provider<double>((ref) {
  final income = ref.watch(monthlyIncomeProvider);
  final expense = ref.watch(monthlyExpenseProvider);
  if (income == 0) return 0;
  return ((income - expense) / income * 100).clamp(0, 100);
});

// ── Top expense ───────────────────────────────────────────────────────────────

final topExpenseCategoryProvider = Provider<CategoryBreakdown?>((ref) {
  final breakdown = ref.watch(expenseBreakdownProvider);
  return breakdown.isNotEmpty ? breakdown.first : null;
});
