import 'package:easy_exchange/services/networking/api-provider.dart';
import 'package:easy_exchange/services/networking/custom-exception.dart';
import 'package:easy_exchange/util/url.dart';
import 'dart:async';
import 'package:easy_exchange/model/currency-rates.dart';
import 'package:intl/intl.dart';

class CurrencyRatesRepository {
  final ApiProvider _provider = ApiProvider();

  Future<CurrencyRates> fetchCurrencyRates() async {
    final response = await _provider.get(Url.getLatestRatesUrl());
    return _parseCurrencyRates(response);
  }

  Future<CurrencyRates> fetchBaseCurrencyRates(String baseCurrency) async {
    final response = await _provider.get(Url.getLatestRatesUrl(baseCurrency));
    return _parseCurrencyRates(response);
  }

  Future<CurrencyRates> fetchSpecificCurrencyRate(
    String originCurrency,
    String destinationCurrency,
  ) async {
    final response = await _provider.get(Url.getLatestRatesUrl(originCurrency));
    return _parseCurrencyRates(response);
  }

  Future<List<HistoricalRates>> fetchRatesHistory(
    String originCurrency,
    String destinationCurrency,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final dates = _generateDateRange(startDate, endDate);
    final historyRates = <HistoricalRates>[];

    for (final date in dates) {
      final formattedDate = dateFormat.format(date);
      final response = await _provider.get(
        Url.getHistoricalRatesUrl(formattedDate, originCurrency),
      );
      
      final rates = _parseCurrencyRates(response);
      final rate = rates.findRate(destinationCurrency);
      
      if (rate != null) {
        historyRates.add(HistoricalRates(
          date: date,
          rate: rate.rate,
        ));
      }
    }

    return historyRates;
  }

  CurrencyRates _parseCurrencyRates(Map<String, dynamic> json) {
    try {
      print('Parsing response: $json'); // Debug log
      
      if (!json.containsKey('rates') || !json.containsKey('base_code')) {
        throw FetchDataException('Missing required fields in response');
      }

      final ratesJson = json['rates'] as Map<String, dynamic>?;
      if (ratesJson == null) {
        throw FetchDataException('Rates data is null');
      }

      final base = json['base_code'] as String? ?? 'USD';
      final rates = <Rate>[];

      ratesJson.forEach((code, value) {
        if (code != base && value is num) {
          // Only add supported currencies
          if (_isSupported(code)) {
            rates.add(Rate(
              currency: Currency(code: code, name: _getCurrencyName(code)),
              rate: value.toDouble(),
            ));
          }
        }
      });

      return CurrencyRates(
        base: Currency(code: base, name: _getCurrencyName(base)),
        rates: rates,
      );
    } catch (e) {
      print('Error parsing currency rates: $e'); // Debug log
      throw FetchDataException('Failed to parse currency rates: $e');
    }
  }

  bool _isSupported(String code) {
    return ['USD', 'SYP', 'LBP', 'AED', 'SAR', 'TRY'].contains(code);
  }

  String _getCurrencyName(String code) {
    final names = {
      'USD': 'US Dollar',
      'SYP': 'Syrian Pound',
      'LBP': 'Lebanese Pound',
      'AED': 'UAE Dirham',
      'SAR': 'Saudi Riyal',
      'TRY': 'Turkish Lira',
    };
    return names[code] ?? code;
  }

  List<DateTime> _generateDateRange(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    return List.generate(
      days + 1,
      (i) => start.add(Duration(days: i)),
    );
  }

  Exception _handleError(dynamic error) {
    if (error is CustomException) {
      return error;
    }
    return FetchDataException(
      'An unexpected error occurred while fetching currency rates: ${error.toString()}',
    );
  }

  void dispose() {
    _provider.dispose();
  }
}
