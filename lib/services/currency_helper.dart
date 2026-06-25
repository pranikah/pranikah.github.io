import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kCurrencyKey = 'user_currency';
const kLocaleKey = 'user_locale';

const currencies = [
  {'code': 'IDR', 'symbol': 'Rp', 'locale': 'id', 'label': 'IDR - Rupiah (Rp)'},
  {'code': 'USD', 'symbol': '\$', 'locale': 'en_US', 'label': 'USD - Dollar (\$)'},
  {'code': 'MYR', 'symbol': 'RM', 'locale': 'ms', 'label': 'MYR - Ringgit (RM)'},
  {'code': 'VND', 'symbol': '₫', 'locale': 'vi', 'label': 'VND - Dong (₫)'},
  {'code': 'GBP', 'symbol': '£', 'locale': 'en_GB', 'label': 'GBP - Pound (£)'},
  {'code': 'EUR', 'symbol': '€', 'locale': 'de', 'label': 'EUR - Euro (€)'},
  {'code': 'SGD', 'symbol': 'S\$', 'locale': 'en_SG', 'label': 'SGD - Singapore Dollar (S\$)'},
];

Future<NumberFormat> getCurrencyFormat() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(kCurrencyKey) ?? 'IDR';
  final entry = currencies.firstWhere((c) => c['code'] == code, orElse: () => currencies[0]);
  return NumberFormat.currency(locale: entry['locale'], symbol: '${entry['symbol']} ', decimalDigits: 0);
}

NumberFormat getCurrencyFormatSync(String currencyCode) {
  final entry = currencies.firstWhere((c) => c['code'] == currencyCode, orElse: () => currencies[0]);
  return NumberFormat.currency(locale: entry['locale'], symbol: '${entry['symbol']} ', decimalDigits: 0);
}
