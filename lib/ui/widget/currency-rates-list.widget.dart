import 'package:easy_exchange/model/currency-rates.dart';
import 'package:easy_exchange/services/bloc/currency-rate-bloc.dart';
import 'package:easy_exchange/services/networking/response.dart';
import 'package:easy_exchange/ui/widget/currencies-bottom-sheet.widget.dart';
import 'package:flutter/material.dart';

class CurrencyRateList extends StatefulWidget {
  final String? searchQuery;
  final Function(String, double)? onCurrencySelected;
  final String baseCurrency;

  const CurrencyRateList({
    super.key,
    this.searchQuery,
    this.onCurrencySelected,
    required this.baseCurrency,
  });

  @override
  State<CurrencyRateList> createState() => _CurrencyRateListState();
}

class _CurrencyRateListState extends State<CurrencyRateList> {
  final CurrencyRatesListBloc _bloc = CurrencyRatesListBloc();

  @override
  void initState() {
    super.initState();
    _bloc.fetchBaseCurrencyRates(widget.baseCurrency);
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
    // First filter by allowed currencies
    var filteredRates = rates.where((rate) => 
      _allowedCurrencies.contains(rate.currency.code)
    ).toList();

    // Then apply search if provided
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      filteredRates = filteredRates.where((rate) {
        final query = widget.searchQuery!.toLowerCase();
        return rate.currency.code.toLowerCase().contains(query) ||
            rate.currency.name.toLowerCase().contains(query);
      }).toList();
    }

    return filteredRates;
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
              if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
                return const Center(
                  child: Text(
                    'No currencies found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              } else {
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
            }
            return ListView.separated(
              itemCount: filteredRates.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final rate = filteredRates[index];
                return ListTile(
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
                  onTap: widget.onCurrencySelected != null
                      ? () => widget.onCurrencySelected!(rate.currency.code, rate.rate)
                      : null,
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
