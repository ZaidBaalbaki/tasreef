import 'package:easy_exchange/services/networking/api-provider.dart';
import 'package:easy_exchange/services/networking/custom-exception.dart';
import 'package:easy_exchange/util/url.dart';
import 'dart:async';
import 'package:easy_exchange/model/currency-rates.dart';
import 'package:intl/intl.dart';

class CurrencyRatesRepository {
  final ApiProvider _provider;

  CurrencyRatesRepository() : _provider = ApiProvider();

  Future<CurrencyRates> fetchCurrencyRates() async {
    try {
      final response = await _provider.get(Url.getLatestRatesUrl());
      return _parseCurrencyRates(response, 'USD');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CurrencyRates> fetchBaseCurrencyRates(String baseCurrency) async {
    try {
      final response = await _provider.get(Url.getLatestRatesUrl(baseCurrency));
      return _parseCurrencyRates(response, baseCurrency);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CurrencyRates> fetchSpecificCurrencyRates(
    String originCurrency,
    String destinationCurrency,
  ) async {
    try {
      final response = await _provider.get(Url.getLatestRatesUrl(originCurrency));
      return _parseCurrencyRates(response, originCurrency);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<HistoricalRates> fetchRatesHistory(
    String originCurrency,
    String destinationCurrency,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final dates = _generateDateRange(start, end);
      final responses = await Future.wait(
        dates.map((date) {
          final dateStr = DateFormat('yyyy-MM-dd').format(date);
          return _provider.get(Url.getHistoricalRatesUrl(dateStr, originCurrency));
        }),
      );

      final rates = responses.asMap().entries.map((entry) {
        final date = dates[entry.key];
        return HistoryRatePoint(
          date,
          _parseCurrencyRates(entry.value, originCurrency).rates,
        );
      }).toList();

      return HistoricalRates(Currency(originCurrency), rates);
    } catch (e) {
      throw _handleError(e);
    }
  }

  CurrencyRates _parseCurrencyRates(Map<String, dynamic> json, String baseCurrency) {
    if (!json.containsKey('rates') || !json.containsKey('base')) {
      throw FormatException('Invalid API response format');
    }

    final rates = json['rates'] as Map<String, dynamic>;
    final ratesMap = <String, dynamic>{
      'base': json['base'],
      'rates': rates,
    };

    return CurrencyRates.fromJson(ratesMap);
  }

  List<DateTime> _generateDateRange(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    return List.generate(
      days + 1,
      (index) => start.add(Duration(days: index)),
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
