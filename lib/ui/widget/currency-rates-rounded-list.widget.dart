import 'package:easy_exchange/model/currency-rates.dart';
import 'package:easy_exchange/services/bloc/currency-rate-bloc.dart';
import 'package:easy_exchange/services/networking/response.dart';
import 'package:easy_exchange/ui/widget/currencies-bottom-sheet.widget.dart';
import 'package:flutter/material.dart';

class CurrencyRateRoundedList extends StatefulWidget {
  final String baseCurrency;
  final CurrencyCallback? onCurrencySelected;

  const CurrencyRateRoundedList({
    super.key,
    required this.baseCurrency,
    this.onCurrencySelected,
  });

  @override
  State<CurrencyRateRoundedList> createState() => _CurrencyRateRoundedListState();
}

class _CurrencyRateRoundedListState extends State<CurrencyRateRoundedList> {
  final CurrencyRatesListBloc _bloc = CurrencyRatesListBloc();

  @override
  void initState() {
    super.initState();
    _bloc.fetchBaseCurrencyRates(widget.baseCurrency);
  }

  @override
  void didUpdateWidget(CurrencyRateRoundedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseCurrency != widget.baseCurrency) {
      _bloc.fetchBaseCurrencyRates(widget.baseCurrency);
    }
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
            final rates = response.data!.rates;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: rates.length,
              itemBuilder: (context, index) {
                final rate = rates[index];
                return InkWell(
                  onTap: widget.onCurrencySelected != null
                      ? () => widget.onCurrencySelected!(rate.currency.code, rate.rate)
                      : null,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            rate.currency.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rate.currency.name,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rate.rate.toStringAsFixed(4),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
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
