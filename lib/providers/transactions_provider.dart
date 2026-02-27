import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'currency_provider.dart';

const _uuid = Uuid();

// ── Date range state ─────────────────────────────────────────────────────────

class DateRange {
  final DateTime from;
  final DateTime to;
  const DateRange({required this.from, required this.to});
}

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

// ── Transactions stream ──────────────────────────────────────────────────────

final transactionsStreamProvider = StreamProvider<List<FinancialTransaction>>((
  ref,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();

  final month = ref.watch(selectedMonthProvider);
  final from = DateTime(month.year, month.month, 1);
  final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

  return ref
      .watch(firestoreServiceProvider)
      .transactionsStream(uid, from: from, to: to);
});

final recentTransactionsProvider = StreamProvider<List<FinancialTransaction>>((
  ref,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).transactionsStream(uid, limit: 20);
});

// ── Summary computations ─────────────────────────────────────────────────────

final monthlyIncomeProvider = Provider<double>((ref) {
  final txs = ref.watch(transactionsStreamProvider).valueOrNull ?? [];
  return txs
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amountInBaseCurrency);
});

final monthlyExpenseProvider = Provider<double>((ref) {
  final txs = ref.watch(transactionsStreamProvider).valueOrNull ?? [];
  return txs
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amountInBaseCurrency);
});

final monthlyBalanceProvider = Provider<double>((ref) {
  return ref.watch(monthlyIncomeProvider) - ref.watch(monthlyExpenseProvider);
});

// ── CRUD notifier ─────────────────────────────────────────────────────────────

class TransactionsNotifier extends StateNotifier<AsyncValue<void>> {
  TransactionsNotifier(this._firestore, this._uid, this._currencyService)
    : super(const AsyncValue.data(null));

  final FirestoreService _firestore;
  final String? _uid;
  final CurrencyServiceNotifier _currencyService;

  Future<bool> addTransaction({
    required TransactionType type,
    required TransactionCategory category,
    required double amount,
    required String currency,
    String? note,
    required DateTime date,
  }) async {
    if (_uid == null) return false;
    state = const AsyncValue.loading();
    try {
      final amountBase = _currencyService.toBase(amount, currency);
      final transaction = FinancialTransaction(
        id: _uuid.v4(),
        userId: _uid,
        type: type,
        category: category,
        amount: amount,
        currency: currency,
        amountInBaseCurrency: amountBase,
        note: note?.trim().isEmpty == true ? null : note?.trim(),
        date: date,
        createdAt: DateTime.now(),
      );
      await _firestore.addTransaction(_uid, transaction);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    if (_uid == null) return false;
    state = const AsyncValue.loading();
    try {
      await _firestore.deleteTransaction(_uid, id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final transactionsNotifierProvider =
    StateNotifierProvider<TransactionsNotifier, AsyncValue<void>>((ref) {
      return TransactionsNotifier(
        ref.watch(firestoreServiceProvider),
        ref.watch(currentUidProvider),
        ref.watch(currencyServiceProvider.notifier),
      );
    });
