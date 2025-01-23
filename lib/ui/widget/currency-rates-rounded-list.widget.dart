import 'package:easy_exchange/model/currency-rates.dart';
import 'package:easy_exchange/services/bloc/currency-rate-bloc.dart';
import 'package:easy_exchange/services/networking/response.dart';
import 'package:flutter/material.dart';

class CurrencyRateRoundedList extends StatefulWidget {
  final String originCurrencyCode;

  const CurrencyRateRoundedList({
    super.key,
    required this.originCurrencyCode,
  });

  @override
  State<CurrencyRateRoundedList> createState() => _CurrencyRateRoundedListState();
}

class _CurrencyRateRoundedListState extends State<CurrencyRateRoundedList> {
  final CurrencyRatesListBloc _bloc = CurrencyRatesListBloc();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(CurrencyRateRoundedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.originCurrencyCode != widget.originCurrencyCode) {
      _fetchData();
    }
  }

  void _fetchData() {
    _bloc.fetchBaseCurrencyRates(widget.originCurrencyCode);
  }

  final List<String> _allowedCurrencies = const [
    'USD',
    'SYP',
    'LBP',
    'AED',
    'SAR',
    'TRY',
  ];

  List<Rate> _filterRates(List<Rate> rates) {
    return rates
        .where((rate) => _allowedCurrencies.contains(rate.currency.code))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Response<CurrencyRates>>(
      stream: _bloc.currencyRatesStream,
      builder: (context, AsyncSnapshot<Response<CurrencyRates>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final response = snapshot.data!;
        switch (response.status) {
          case Status.LOADING:
            return const Center(child: CircularProgressIndicator());
          case Status.COMPLETED:
            final filteredRates = _filterRates(response.data!.rates);
            if (filteredRates.isEmpty) {
              return const Center(
                child: Text(
                  'No rates available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredRates.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final rate = filteredRates[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      rate.currency.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(rate.currency.name),
                    trailing: Text(
                      rate.rate.toStringAsFixed(4),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            );
          case Status.ERROR:
            return Center(
              child: Text(
                'Error: ${response.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
        }
      },
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
