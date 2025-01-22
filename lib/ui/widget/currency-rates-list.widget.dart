import 'package:easy_exchange/model/currency-rates.dart';
import 'package:easy_exchange/services/bloc/currency-rate-bloc.dart';
import 'package:easy_exchange/services/networking/response.dart';
import 'package:easy_exchange/ui/widget/currencies-bottom-sheet.widget.dart';
import 'package:flutter/material.dart';

class CurrencyRateList extends StatefulWidget {
  final String baseCurrency;
  final CurrencyCallback? onCurrencySelected;
  final String? searchQuery;

  const CurrencyRateList({
    super.key,
    required this.baseCurrency,
    this.onCurrencySelected,
    this.searchQuery,
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

  @override
  void didUpdateWidget(CurrencyRateList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseCurrency != widget.baseCurrency) {
      _bloc.fetchBaseCurrencyRates(widget.baseCurrency);
    }
  }

  List<Rate> _filterRates(List<Rate> rates) {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return rates;
    }
    return rates.where((rate) {
      return rate.currency.code.toLowerCase().contains(widget.searchQuery!) ||
          rate.currency.name.toLowerCase().contains(widget.searchQuery!);
    }).toList();
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
            if (filteredRates.isEmpty && widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
              return const Center(
                child: Text(
                  'No currencies found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              );
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
