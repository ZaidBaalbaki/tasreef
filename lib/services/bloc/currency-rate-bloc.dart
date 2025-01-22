import 'dart:async';

import 'package:easy_exchange/services/networking/response.dart';
import 'package:easy_exchange/services/repository/currency-rates-repository.dart';
import 'package:easy_exchange/model/currency-rates.dart';
import 'package:rxdart/rxdart.dart';

class CurrencyRatesListBloc {
  final CurrencyRatesRepository _repository;
  final BehaviorSubject<Response<CurrencyRates>> _ratesController;
  final BehaviorSubject<Response<HistoricalRates>> _historyController;
  final BehaviorSubject<String?> _errorController;

  CurrencyRatesListBloc()
      : _repository = CurrencyRatesRepository(),
        _ratesController = BehaviorSubject<Response<CurrencyRates>>(),
        _historyController = BehaviorSubject<Response<HistoricalRates>>(),
        _errorController = BehaviorSubject<String?>();

  // Stream getters
  Stream<Response<CurrencyRates>> get currencyRatesStream => _ratesController.stream;
  Stream<Response<HistoricalRates>> get historyRatesStream => _historyController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  // Current values getters
  Response<CurrencyRates>? get currentRates => _ratesController.valueOrNull;
  Response<HistoricalRates>? get currentHistory => _historyController.valueOrNull;

  Future<void> fetchBaseCurrencyRates(String baseCurrency) async {
    _ratesController.add(Response.loading('Getting Currency Rates...'));
    try {
      final currencyRates = await _repository.fetchBaseCurrencyRates(baseCurrency);
      _ratesController.add(Response.completed(currencyRates));
      _errorController.add(null);
    } catch (e) {
      final errorMsg = 'Error fetching currency rates: ${e.toString()}';
      _ratesController.add(Response.error(errorMsg));
      _errorController.add(errorMsg);
    }
  }

  Future<void> fetchSpecificCurrencyRate(
    String originCurrency,
    String destinationCurrency,
  ) async {
    _ratesController.add(Response.loading('Getting Specific Rate...'));
    try {
      final rate = await _repository.fetchSpecificCurrencyRates(
        originCurrency,
        destinationCurrency,
      );
      _ratesController.add(Response.completed(rate));
      _errorController.add(null);
    } catch (e) {
      final errorMsg = 'Error fetching specific rate: ${e.toString()}';
      _ratesController.add(Response.error(errorMsg));
      _errorController.add(errorMsg);
    }
  }

  Future<void> fetchRatesHistory(
    String originCurrency,
    String destinationCurrency,
    DateTime start,
    DateTime end,
  ) async {
    _historyController.add(Response.loading('Getting Historical Rates...'));
    try {
      final history = await _repository.fetchRatesHistory(
        originCurrency,
        destinationCurrency,
        start,
        end,
      );
      _historyController.add(Response.completed(history));
      _errorController.add(null);
    } catch (e) {
      final errorMsg = 'Error fetching rate history: ${e.toString()}';
      _historyController.add(Response.error(errorMsg));
      _errorController.add(errorMsg);
    }
  }

  Future<void> refreshCurrentRates() async {
    final currentResponse = _ratesController.valueOrNull;
    if (currentResponse?.data?.baseCurrency.code != null) {
      await fetchBaseCurrencyRates(currentResponse!.data!.baseCurrency.code);
    }
  }

  void dispose() {
    _ratesController.close();
    _historyController.close();
    _errorController.close();
    _repository.dispose();
  }
}