import 'package:easy_exchange/ui/widget/currency-button.widget.dart';
import 'package:easy_exchange/ui/widget/currency-history-graph.widget.dart';
import 'package:easy_exchange/ui/widget/currencies-bottom-sheet.widget.dart';
import 'package:flutter/material.dart';

class GraphsPage extends StatefulWidget {
  const GraphsPage({super.key});

  @override
  State<GraphsPage> createState() => _GraphsPageState();
}

class _GraphsPageState extends State<GraphsPage> {
  String _originCurrencyCode = 'USD';
  String _destinationCurrencyCode = 'EUR';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = '1M';
  Key _graphKey = UniqueKey();

  void _updatePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case '1W':
          _startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case '1M':
          _startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case '3M':
          _startDate = DateTime.now().subtract(const Duration(days: 90));
          break;
        case '6M':
          _startDate = DateTime.now().subtract(const Duration(days: 180));
          break;
        case '1Y':
          _startDate = DateTime.now().subtract(const Duration(days: 365));
          break;
      }
      _endDate = DateTime.now();
      _graphKey = UniqueKey(); // Force graph rebuild
    });
  }

  Future<void> _selectCurrency(bool isOrigin) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CurrenciesBottomSheet(
          baseCurrency: isOrigin ? _destinationCurrencyCode : _originCurrencyCode,
          onCurrencySelected: (code, rate) {
            Navigator.pop(context, {'code': code, 'rate': rate});
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        if (isOrigin) {
          _originCurrencyCode = result['code'];
        } else {
          _destinationCurrencyCode = result['code'];
        }
        _graphKey = UniqueKey(); // Force graph rebuild
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CurrencyButton(
                currencyCode: _originCurrencyCode,
                onPressed: () => _selectCurrency(true),
              ),
              const Icon(Icons.compare_arrows),
              CurrencyButton(
                currencyCode: _destinationCurrencyCode,
                onPressed: () => _selectCurrency(false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['1W', '1M', '3M', '6M', '1Y'].map((period) {
                final isSelected = period == _selectedPeriod;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () => _updatePeriod(period),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.white,
                      foregroundColor: isSelected ? Colors.white : Theme.of(context).primaryColor,
                      elevation: isSelected ? 2 : 1,
                    ),
                    child: Text(period),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CurrencyHistoryGraph(
              key: _graphKey,
              originCurrencyCode: _originCurrencyCode,
              destinationCurrencyCode: _destinationCurrencyCode,
              startDate: _startDate,
              endDate: _endDate,
            ),
          ),
        ],
      ),
    );
  }
}
