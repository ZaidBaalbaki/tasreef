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
  String? _error;

  @override
  void initState() {
    super.initState();
    _originAmountController.addListener(_updateDestinationAmount);
    _fetchRate();
  }

  Future<void> _fetchRate() async {
    setState(() => _error = null);
    try {
      await _bloc.fetchSpecificCurrencyRate(
        _originCurrencyCode,
        _destinationCurrencyCode,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _updateDestinationAmount() {
    if (_originAmountController.text.isEmpty) {
      _destinationAmountController.text = '';
      return;
    }

    try {
      final amount = double.tryParse(_originAmountController.text);
      if (amount == null) {
        _destinationAmountController.text = '';
        return;
      }

      if (_rate <= 0) {
        _destinationAmountController.text = '';
        setState(() => _error = 'Invalid exchange rate');
        return;
      }

      final convertedAmount = amount * _rate;
      _destinationAmountController.text = convertedAmount.toStringAsFixed(2);
      setState(() => _error = null);
    } catch (e) {
      _destinationAmountController.text = '';
      setState(() => _error = 'Error converting amount');
    }
  }

  void _swapCurrencies() {
    if (_rate <= 0) {
      setState(() => _error = 'Cannot swap with invalid rate');
      return;
    }

    setState(() {
      final tempCurrency = _originCurrencyCode;
      _originCurrencyCode = _destinationCurrencyCode;
      _destinationCurrencyCode = tempCurrency;
      _rate = 1 / _rate;
      
      // Swap amounts
      final tempAmount = _originAmountController.text;
      _originAmountController.text = _destinationAmountController.text;
      _destinationAmountController.text = tempAmount;
      _error = null;
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
              if (rate != null && rate > 0) {
                _rate = isOrigin ? 1 / rate : rate;
                _updateDestinationAmount();
              }
              _error = null;
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
          if (rate != null && rate.rate > 0) {
            _rate = rate.rate;
            _updateDestinationAmount();
          } else {
            _error = 'Rate not available';
          }
        } else if (snapshot.hasData && snapshot.data!.status == Status.ERROR) {
          _error = snapshot.data!.message;
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
                enabled: false,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (_rate > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    '1 $_originCurrencyCode = ${_rate.toStringAsFixed(4)} $_destinationCurrencyCode',
                    style: Theme.of(context).textTheme.bodyLarge,
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
