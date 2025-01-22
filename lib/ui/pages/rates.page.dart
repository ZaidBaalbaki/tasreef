import 'package:easy_exchange/ui/widget/currency-button.widget.dart';
import 'package:easy_exchange/ui/widget/currencies-bottom-sheet.widget.dart';
import 'package:easy_exchange/ui/widget/currency-rates-list.widget.dart';
import 'package:easy_exchange/ui/widget/currency-rates-rounded-list.widget.dart';
import 'package:flutter/material.dart';

class RatesPage extends StatefulWidget {
  const RatesPage({super.key});

  @override
  State<RatesPage> createState() => _RatesPageState();
}

class _RatesPageState extends State<RatesPage> {
  String _originCurrencyCode = 'USD';
  bool _showRoundedList = false;

  void _selectCurrency() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CurrenciesBottomSheet(
          baseCurrency: _originCurrencyCode,
          onCurrencySelected: (code, rate) {
            setState(() {
              _originCurrencyCode = code;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _onCurrencySelected(String code, double? rate) {
    setState(() {
      _originCurrencyCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CurrencyButton(
                currencyCode: _originCurrencyCode,
                onPressed: _selectCurrency,
              ),
              IconButton(
                icon: Icon(
                  _showRoundedList ? Icons.view_list : Icons.view_module,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _showRoundedList = !_showRoundedList;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _showRoundedList
                ? CurrencyRateRoundedList(
                    baseCurrency: _originCurrencyCode,
                    onCurrencySelected: _onCurrencySelected,
                  )
                : CurrencyRateList(
                    baseCurrency: _originCurrencyCode,
                    onCurrencySelected: _onCurrencySelected,
                  ),
          ),
        ],
      ),
    );
  }
}