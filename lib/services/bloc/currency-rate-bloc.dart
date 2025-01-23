import 'dart:async';

import 'package:easy_exchange/services/networking/response.dart';
import 'package:easy_exchange/services/repository/currency-rates-repository.dart';
import 'package:easy_exchange/model/currency-rates.dart';
import 'package:rxdart/rxdart.dart';

class CurrencyRatesListBloc {
  final CurrencyRatesRepository _repository = CurrencyRatesRepository();
  final BehaviorSubject<Response<CurrencyRates>> _subject = BehaviorSubject<Response<CurrencyRates>>();
  final BehaviorSubject<Response<List<HistoricalRates>>> _historyController = BehaviorSubject<Response<List<HistoricalRates>>>();

  Stream<Response<CurrencyRates>> get currencyRatesStream => _subject.stream;
  Stream<Response<List<HistoricalRates>>> get historyRatesStream => _historyController.stream;

  Future<void> fetchCurrencyRates() async {
    _subject.add(Response.loading('Getting currency rates...'));
    try {
      final rates = await _repository.fetchCurrencyRates();
      _subject.add(Response.completed(rates));
    } catch (e) {
      _subject.add(Response.error(e.toString()));
    }
  }

  Future<void> fetchBaseCurrencyRates(String baseCurrency) async {
    _subject.add(Response.loading('Getting rates for $baseCurrency...'));
    try {
      final rates = await _repository.fetchBaseCurrencyRates(baseCurrency);
      _subject.add(Response.completed(rates));
    } catch (e) {
      _subject.add(Response.error(e.toString()));
    }
  }

  Future<void> fetchSpecificCurrencyRate(
    String originCurrency,
    String destinationCurrency,
  ) async {
    _subject.add(Response.loading('Getting rate for $originCurrency to $destinationCurrency...'));
    try {
      final rates = await _repository.fetchSpecificCurrencyRate(
        originCurrency,
        destinationCurrency,
      );
      _subject.add(Response.completed(rates));
    } catch (e) {
      _subject.add(Response.error(e.toString()));
    }
  }

  Future<void> fetchRatesHistory(
    String originCurrency,
    String destinationCurrency,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _historyController.add(Response.loading('Getting historical rates...'));
    try {
      final history = await _repository.fetchRatesHistory(
        originCurrency,
        destinationCurrency,
        startDate,
        endDate,
      );
      _historyController.add(Response.completed(history));
    } catch (e) {
      _historyController.add(Response.error(e.toString()));
    }
  }

  void dispose() {
    _subject.close();
    _historyController.close();
  }
}