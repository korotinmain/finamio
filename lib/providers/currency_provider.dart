import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/currency_service.dart';

const _baseCurrencyKey = 'base_currency';

// ── Currency service notifier ─────────────────────────────────────────────────

class CurrencyServiceNotifier extends StateNotifier<String> {
  CurrencyServiceNotifier(this._service) : super('USD');

  final CurrencyService _service;

  Future<void> initialise() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_baseCurrencyKey) ?? 'USD';
    state = saved;
    await _service.initialise();
  }

  Future<void> setBaseCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseCurrencyKey, code);
    state = code;
  }

  double toBase(double amount, String fromCurrency) =>
      _service.convert(amount, from: fromCurrency, to: 'USD');

  double convert(double amount, {required String from, required String to}) =>
      _service.convert(amount, from: from, to: to);

  String get baseCurrencySymbol => CurrencyService.symbolFor(state);
}

final currencyServiceProvider =
    StateNotifierProvider<CurrencyServiceNotifier, String>((ref) {
      return CurrencyServiceNotifier(CurrencyService());
    });

final baseCurrencySymbolProvider = Provider<String>((ref) {
  final code = ref.watch(currencyServiceProvider);
  return CurrencyService.symbolFor(code);
});

final supportedCurrenciesProvider = Provider<List<Currency>>((ref) {
  return CurrencyService.supportedCurrencies;
});
