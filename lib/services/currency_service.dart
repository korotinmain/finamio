import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

class CurrencyService {
  static const String _ratesKey = 'fx_rates';
  static const String _ratesTimestampKey = 'fx_rates_ts';
  static const Duration _cacheDuration = Duration(hours: 6);

  // Free tier – no API key required for base USD
  static const String _apiUrl =
      'https://api.exchangerate-api.com/v4/latest/USD';

  final Logger _log = Logger();

  Map<String, double> _rates = {'USD': 1.0};

  static const List<Currency> supportedCurrencies = [
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr'),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'CA\$'),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
    Currency(code: 'MXN', name: 'Mexican Peso', symbol: 'MX\$'),
    Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
    Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$'),
    Currency(code: 'UAH', name: 'Ukrainian Hryvnia', symbol: '₴'),
    Currency(code: 'PLN', name: 'Polish Zloty', symbol: 'zł'),
    Currency(code: 'TRY', name: 'Turkish Lira', symbol: '₺'),
    Currency(code: 'RUB', name: 'Russian Ruble', symbol: '₽'),
    Currency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr'),
    Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr'),
  ];

  static String symbolFor(String code) {
    return supportedCurrencies
        .firstWhere(
          (c) => c.code == code,
          orElse: () => Currency(code: code, name: code, symbol: code),
        )
        .symbol;
  }

  Future<void> initialise() async {
    await _loadFromCache();
    if (_shouldRefresh()) {
      await _fetchRates();
    }
  }

  double convert(double amount, {required String from, required String to}) {
    if (from == to) return amount;
    final fromRate = _rates[from] ?? 1.0;
    final toRate = _rates[to] ?? 1.0;
    return amount / fromRate * toRate;
  }

  double toBase(double amount, String fromCurrency) =>
      convert(amount, from: fromCurrency, to: 'USD');

  // ── Private helpers ──────────────────────────────────────────────────────
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_ratesKey);
      if (json != null) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _rates = map.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    } catch (e) {
      _log.w('Could not load cached rates: $e');
    }
  }

  bool _shouldRefresh() {
    return true; // Always refresh on init in this simple version
  }

  Future<void> _fetchRates() async {
    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawRates = data['rates'] as Map<String, dynamic>;
        _rates = rawRates.map((k, v) => MapEntry(k, (v as num).toDouble()));
        _rates['USD'] = 1.0;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_ratesKey, jsonEncode(_rates));
        await prefs.setInt(
          _ratesTimestampKey,
          DateTime.now().millisecondsSinceEpoch,
        );
        _log.i('FX rates updated');
      }
    } catch (e) {
      _log.w('Could not fetch FX rates: $e');
    }
  }
}
