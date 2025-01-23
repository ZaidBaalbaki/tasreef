import 'package:easy_exchange/model/currency-rates.dart';
import 'package:easy_exchange/services/bloc/currency-rate-bloc.dart';
import 'package:easy_exchange/services/networking/response.dart';
import 'package:easy_exchange/ui/widget/amount-input.widget.dart';
import 'package:easy_exchange/ui/widget/currencies-bottom-sheet.widget.dart';
import 'package:easy_exchange/ui/widget/currency-button.widget.dart';
import 'package:flutter/material.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final _originAmountController = TextEditingController();
  final _destinationAmountController = TextEditingController();
  final CurrencyRatesListBloc _bloc = CurrencyRatesListBloc();
  String _originCurrencyCode = 'USD';
  String _destinationCurrencyCode = 'SYP';
  double _rate = 0.0;

  @override
  void initState() {
    super.initState();
    _originAmountController.addListener(_updateDestinationAmount);
    _fetchRate();
  }

  Future<void> _fetchRate() async {
    await _bloc.fetchSpecificCurrencyRate(
      _originCurrencyCode,
      _destinationCurrencyCode,
    );
  }

  void _updateDestinationAmount() {
    if (_originAmountController.text.isEmpty) {
      _destinationAmountController.text = '';
      return;
    }

    final amount = double.tryParse(_originAmountController.text) ?? 0;
    final convertedAmount = amount * _rate;
    _destinationAmountController.text = convertedAmount.toStringAsFixed(2);
  }

  void _swapCurrencies() {
    setState(() {
      final tempCurrency = _originCurrencyCode;
      _originCurrencyCode = _destinationCurrencyCode;
      _destinationCurrencyCode = tempCurrency;
      _rate = 1 / _rate;
      
      // Swap amounts
      final tempAmount = _originAmountController.text;
      _originAmountController.text = _destinationAmountController.text;
      _destinationAmountController.text = tempAmount;
    });
    _fetchRate();
  }

  void _selectCurrency(bool isOrigin) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CurrenciesBottomSheet(
          baseCurrency: isOrigin ? _destinationCurrencyCode : _originCurrencyCode,
          onCurrencySelected: (code, rate) {
            setState(() {
              if (isOrigin) {
                _originCurrencyCode = code;
              } else {
                _destinationCurrencyCode = code;
              }
              if (rate != null) {
                _rate = isOrigin ? 1 / rate : rate;
                _updateDestinationAmount();
              }
            });
            Navigator.pop(context);
            _fetchRate();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Response<CurrencyRates>>(
      stream: _bloc.currencyRatesStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.status == Status.COMPLETED) {
          final rate = snapshot.data!.data!.findRate(_destinationCurrencyCode);
          if (rate != null) {
            _rate = rate.rate;
            _updateDestinationAmount();
          }
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AmountInput(
                controller: _originAmountController,
                currencyCode: _originCurrencyCode,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CurrencyButton(
                    currencyCode: _originCurrencyCode,
                    onPressed: () => _selectCurrency(true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: _swapCurrencies,
                  ),
                  CurrencyButton(
                    currencyCode: _destinationCurrencyCode,
                    onPressed: () => _selectCurrency(false),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AmountInput(
                controller: _destinationAmountController,
                currencyCode: _destinationCurrencyCode,
              ),
              if (snapshot.hasData && snapshot.data!.status == Status.COMPLETED)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    '1 $_originCurrencyCode = $_rate $_destinationCurrencyCode',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              if (snapshot.hasData && snapshot.data!.status == Status.ERROR)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Error: ${snapshot.data!.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _originAmountController.dispose();
    _destinationAmountController.dispose();
    _bloc.dispose();
    super.dispose();
  }
}
